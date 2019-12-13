//
//  CdnTask.m
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnSnsUploadTask.h"
#import <FastSocket.h>
#import "GetCDNDnsService.h"
#import "DeviceManager.h"
#import <zlib.h>
#import "FSOpenSSL.h"
#import "AES_EVP.h"

@interface CdnSnsUploadTask()

@property (nonatomic, strong) FastSocket *client;
@property (nonatomic, strong) NSMutableData *body;
@property (nonatomic, assign) NSUInteger seq;

@property (nonatomic, strong) dispatch_queue_t readSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writeSerialQueue;

@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailureBlock failureBlock;

@end

@implementation CdnSnsUploadTask

- (instancetype)initWithSeq:(NSUInteger)seq {
    self = [super init];
    if (self) {
        _body = [NSMutableData data];
        _seq = seq;
        
        _readSerialQueue = dispatch_queue_create("me.ray.CDN.Read", DISPATCH_QUEUE_SERIAL);
        _writeSerialQueue = dispatch_queue_create("me.ray.CDN.Write", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - NetWork

- (void)startC2CUpload:(NSString *)picPath
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock {
    
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    
    NSData *data = [self packData:picPath];
    NSString *ip = [self getSNDCdnIp];
    LogVerbose(@"SNSCDN Use Ip: %@", ip);
    FastSocket *client = [[FastSocket alloc] initWithHost:ip andPort:@"443"];
    if ([client connect]) {
        _client = client;
        [self _sendData:data];
        [self readData];
    }
}


- (void)_sendData:(NSData *)sendData
{
    dispatch_async(_writeSerialQueue, ^{
        long sent = [self.client sendBytes:[sendData bytes] count:[sendData length]];
        if (sent == sendData.length)
        {
            LogDebug(@"FastSocket Send all the Data, Len: %ld", sent);
        }
        else
        {
            LogError(@"FastSocket Send Only %ld Bytes.", sent);
        }
    });
}

- (void)readData
{
    dispatch_async(_readSerialQueue, ^{
        while (1)
        {
            NSData *dataPackage = [self ReadCDNPacket];
            if ([dataPackage toInt8ofRange:0] == 0xab) //mmtls handshake
            {
                LogVerbose(@"cdn recv packet: %@", [FSOpenSSL data2HexString:dataPackage]);
                NSDictionary *response = [self parseResponseToDic:dataPackage];
                LogVerbose(@"cdn recv response: %@", response);
                
                if ([response objectForKey:@"fileurl"] && [response objectForKey:@"thumburl"] && self.successBlock) {
                    self.successBlock(response);
                    [self.client close];
                    break;
                }
            }
            else
            {
                //error ?
            }
        }
    });
}

- (NSData *)ReadCDNPacket
{
    NSMutableData *header = [NSMutableData dataWithLength:5];
    long received = [_client receiveBytes:[header mutableBytes] count:5];
    if (received == 5)
    {
        //LogInfo(@"Read 5 bytes Head.");
    }

    int32_t payloadLength = [header toInt16ofRange:NSMakeRange(3, 2) SwapBigToHost:YES];
    NSData *payloadData = [self readPayload:payloadLength - 5];
    [header appendData:payloadData];

    return [header copy];
}

- (NSData *)readPayload:(NSInteger)payloadLength
{
    NSMutableData *payload = [NSMutableData dataWithLength:payloadLength];
    long received = [_client receiveBytes:[payload mutableBytes] count:payloadLength];
    if (received == payloadLength)
    {
        return [payload copy];
    }
    else
    {
        LogError(@"Read Payload not match expect.");
        return nil;
    }
}

#pragma mark - Request

- (void)writeField:(NSString *)field WithValue:(id)value {
    [_body appendData:[NSData packInt32:(int) field.length flip:YES]]; // 字段名 长度
    [_body appendData:[field dataUsingEncoding:NSUTF8StringEncoding]]; // 字段名 内容
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString *v = (NSString *) value;
        [_body appendData:[NSData packInt32:(int) v.length flip:YES]]; // 字段 长度
        [_body appendData:[v dataUsingEncoding:NSUTF8StringEncoding]]; // 字段 内容
    }
    
    else if ([value isKindOfClass:[NSData class]]) {
        NSData *d = (NSData *) value;
        [_body appendData:[NSData packInt32:(int) d.length flip:YES]]; // 字段 长度
        [_body appendData:d];                                          // 字段 内容
    }
}

- (void)packBody: (NSString *)picPath {
    CDNDnsInfo *snsDNSInfo = [self getSnsDnsInfo];
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    NSData *picData = [NSData dataWithContentsOfFile:picPath];

    NSData *aesKey = [FSOpenSSL random128BitAESKey];
    NSData *aesPicData = [AES_EVP AES_ECB_128_Encrypt:picData key:aesKey];
    unsigned long aesPicDataAdler32 = adler32(0, [aesPicData bytes], (unsigned int) [aesPicData length]);
    
    
    NSString *N = @"BFEDFFB5EA28509F9C89ED83FA7FDDA8"
                   "881435D444E984D53A98AD8E9410F114"
                   "5EDD537890E10456190B22E6E5006455"
                   "EFC6C12E41FDA985F38FBBC7213ECB81"
                   "0E3053D4B8D74FFBC70B4600ABD72820"
                   "2322AFCE1406046631261BD5EE3D4472"
                   "1082FEAB74340D73645DC0D02A293B96"
                   "2B9D47E4A64100BD7524DE00D9D3B5C1";
    
    NSString *E = @"10001";
    
    NSData *rsaValue = [FSOpenSSL RSA_PUB_EncryptData:aesKey modulus:N exponent:E];
    
    [self writeField:@"ver" WithValue:@"1"]; //uin
    [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%d", snsDNSInfo.uin]]; //uin
    [self writeField:@"seq" WithValue:[NSString stringWithFormat:@"%ld", _seq]];
    [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //微信版本
    [self writeField:@"clientostype" WithValue:[[NSString alloc] initWithData:[device osType] encoding:NSUTF8StringEncoding]]; // iOS12.4
    [self writeField:@"authkey" WithValue:snsDNSInfo.authKey.buffer]; //0x45长度 69 // /cgi-bin/micromsg-bin/getcdndns GetCDNDnsResponse snsDnsInfo authKey
    [self writeField:@"nettype" WithValue:@"1"];
    [self writeField:@"acceptdupack" WithValue:@"1"];
    [self writeField:@"rsaver" WithValue:@"1"];
    [self writeField:@"rsavalue" WithValue:rsaValue]; //0x80长度
    [self writeField:@"filetype" WithValue:@"20201"]; // 固定
    [self writeField:@"wxchattype" WithValue:@"0"];
    [self writeField:@"lastretcode" WithValue:@"0"];
    [self writeField:@"ipseq" WithValue:@"0"];
    [self writeField:@"isstorevideo" WithValue:@"0"];
    [self writeField:@"nocheckaeskey" WithValue:@"1"];
    [self writeField:@"enablehit" WithValue:@"1"];
    [self writeField:@"existancecheck" WithValue:@"0"];
    [self writeField:@"apptype" WithValue:@"107"]; // 固定
    NSString *fileKey = [FSOpenSSL md5StringFromString:[NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]]];
    [self writeField:@"filekey" WithValue:fileKey]; //md5(SystemClock.elapsedRealtime())
    [self writeField:@"totalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"rawtotalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"localname" WithValue:@"sns_tmpb_Locall_path3"];
    [self writeField:@"offset" WithValue:@"0"];
    [self writeField:@"hasthumb" WithValue:@"0"];
    [self writeField:@"thumbtotalsize" WithValue:@"0"];
    [self writeField:@"rawthumbsize" WithValue:@"0"];
    [self writeField:@"rawthumbmd5" WithValue:[NSData data]];
    [self writeField:@"thumbcrc" WithValue:@"0"];
    [self writeField:@"largesvideo" WithValue:@"0"];
    [self writeField:@"sourceflag" WithValue:@"0"];
    [self writeField:@"advideoflag" WithValue:@"0"];
    
    NSString *picMD5 = [FSOpenSSL md5StringFromData:picData];
    [self writeField:@"filemd5" WithValue:picMD5]; // file md5
    [self writeField:@"rawfilemd5" WithValue:picMD5]; // file md5
    [self writeField:@"datachecksum" WithValue:[NSString stringWithFormat:@"%ld", aesPicDataAdler32]];

    unsigned long picAdler32 = adler32(0, [picData bytes], (unsigned int) [picData length]);
    [self writeField:@"filecrc" WithValue:[NSString stringWithFormat:@"%ld", picAdler32]]; // adler32 of file
    
    [self writeField:@"filedata" WithValue:picData];
}

- (NSData *)packData:(NSString *)picPath {
    [self packBody:picPath];
    
    NSMutableData *header = [NSMutableData data];
    [header appendData:[NSData dataWithHexString:@"AB"]];   //固定
    [header appendData:[NSData packInt32:(int) (_body.length + 25) flip:YES]]; // 包长 + 包头长
    [header appendData:[NSData dataWithHexString:@"27127916e88600000000000000000000"]];   //固定
    [header appendData:[NSData packInt32:(int) _body.length flip:YES]]; // 包长
    [header appendData:_body];
    return header;
}


#pragma mark - Parse Response

- (NSDictionary *)parseResponseToDic:(NSData *)cdnPacketData {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSString *key = nil;
    NSString *value = nil;
    int pos = 25;
    while ([self readField:&key andValue:&value withReponse:cdnPacketData pos:&pos]) {
        [md setObject:value forKey:key];
        LogVerbose(@"key: %@, value: %@", key, value);
    };
    
    return [md copy];
}

- (BOOL)readField:(NSString **)field andValue:(NSString **)value withReponse:(NSData *)responseData pos:(int *)pos {
    int index = *pos;
    if (index >= [responseData length]) return NO;
    
    // read key
    int32_t keyLen = [responseData toInt32ofRange:NSMakeRange(index, 4) SwapBigToHost:YES];
    NSData *KeyData = [responseData subdataWithRange:NSMakeRange(index + 4, keyLen)];
    *field = [[NSString alloc] initWithData:KeyData encoding:NSUTF8StringEncoding];
    index = index + 4 + keyLen;
    
    // read value
    int32_t vLen = [responseData toInt32ofRange:NSMakeRange(index, 4) SwapBigToHost:YES];
    NSData *valueData = [responseData subdataWithRange:NSMakeRange(index + 4, vLen)];
    NSString *vString = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    
    if ([vString length])
        *value = vString;
    else
        *value = [FSOpenSSL data2HexString:valueData];
    
    index = index + 4 + vLen;
    
    *pos = index; // record pos
    return index <= [responseData length];
}


#pragma mark - Helper

- (NSString *)getSNDCdnIp {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return [resp.snsDnsInfo.frontIplistArray objectAtIndex:0].string;
}

- (CDNDnsInfo *)getSnsDnsInfo {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return resp.snsDnsInfo;
}

@end
