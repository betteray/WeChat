//
//  CdnSendPictureTask.m
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnSendPictureTask.h"
#import "FSOpenSSL.h"
#import "AES_EVP.h"
#import <zlib.h>
#import "GetCDNDnsService.h"

@interface CdnSendPictureTask ()

@property (nonatomic, strong) NSMutableData *body;
@property (nonatomic, assign) NSUInteger seq;

@end

@implementation CdnSendPictureTask

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

    NSData *aesKey = [NSData dataWithHexString:@"A81161C9F70A1B7DA8BCA0A892652187"];//[FSOpenSSL random128BitAESKey];
    NSData *aesPicData = [AES_EVP AES_ECB_128_Encrypt:picData key:aesKey];
    unsigned long aesPicDataAdler32 = adler32(0, [aesPicData bytes], (unsigned int) [aesPicData length]);
    
//    NSString *N = @"BFEDFFB5EA28509F9C89ED83FA7FDDA8"  //1 16byte
//                   "881435D444E984D53A98AD8E9410F114"  //2 16byte
//                   "5EDD537890E10456190B22E6E5006455"  //3 16byte
//                   "EFC6C12E41FDA985F38FBBC7213ECB81"  //4 16byte
//                   "0E3053D4B8D74FFBC70B4600ABD72820"  //5 16byte
//                   "2322AFCE1406046631261BD5EE3D4472"  //6 16byte
//                   "1082FEAB74340D73645DC0D02A293B96"  //7 16byte
//                   "2B9D47E4A64100BD7524DE00D9D3B5C1"; //8 16byte  // 16 * 8 = 128 byte
//
//    NSString *E = @"10001";
//
//    NSData *rsaValue = [FSOpenSSL RSA_PUB_EncryptData:aesKey modulus:N exponent:E];
    
    [self writeField:@"ver" WithValue:@"1"]; //uin
    [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%d", snsDNSInfo.uin]]; //uin
    [self writeField:@"seq" WithValue:[NSString stringWithFormat:@"%ld", _seq]];
    [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //微信版本
    [self writeField:@"clientostype" WithValue:[[NSString alloc] initWithData:[device osType] encoding:NSUTF8StringEncoding]]; // iOS12.4
    [self writeField:@"authkey" WithValue:snsDNSInfo.authKey.buffer]; //0x45长度 69 // /cgi-bin/micromsg-bin/getcdndns GetCDNDnsResponse snsDnsInfo authKey
    [self writeField:@"nettype" WithValue:@"1"];
    [self writeField:@"acceptdupack" WithValue:@"1"];
    [self writeField:@"safeproto" WithValue:@"1"]; // chat add
    [self writeField:@"filetype" WithValue:@"2"]; //
    [self writeField:@"wxchattype" WithValue:@"0"];
    [self writeField:@"lastretcode" WithValue:@"0"];
    [self writeField:@"ipseq" WithValue:@"0"];
    [self writeField:@"\"cli-quic-flag\"" WithValue:@"0"]; // chat add
    [self writeField:@"hasthumb" WithValue:@"1"];
    [self writeField:@"touser" WithValue:@"@cdn2_50126cde0fb944757378bd531cec799d"]; // chat add @cdn2_50126cde0fb944757378bd531cec799d ??
    [self writeField:@"compresstype" WithValue:@"0"];
    [self writeField:@"nocheckaeskey" WithValue:@"1"];
    [self writeField:@"enablehit" WithValue:@"1"];
    [self writeField:@"existancecheck" WithValue:@"0"];
    [self writeField:@"apptype" WithValue:@"1"]; // 固定
    NSString *fileKey = [FSOpenSSL md5StringFromString:[NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]]];
    [self writeField:@"filekey" WithValue:fileKey]; //android=md5(SystemClock.elapsedRealtime()) // ios=wxupload_rowhongwei3_1575873581
    [self writeField:@"totalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"rawtotalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"localname" WithValue:@"sns_tmpb_Locall_path3"];
    [self writeField:@"sessionbuf" WithValue:@""]; // ?
    [self writeField:@"offset" WithValue:@"0"];
    [self writeField:@"thumbtotalsize" WithValue:[NSString stringWithFormat:@"%ld", [aesPicData length]]];
    [self writeField:@"rawthumbsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]];
    NSString *picMD5 = [FSOpenSSL md5StringFromData:picData];
    [self writeField:@"rawthumbmd5" WithValue:picMD5]; //ok
    [self writeField:@"encthumbcrc" WithValue:[NSString stringWithFormat:@"%ld", aesPicDataAdler32]];// ok
    
    [self writeField:@"thumbdata" WithValue:aesPicData]; //ok
    [self writeField:@"largesvideo" WithValue:@"0"];
    [self writeField:@"sourceflag" WithValue:@"0"];
    [self writeField:@"advideoflag" WithValue:@"0"];
    
//    [self writeField:@"filemd5" WithValue:picMD5]; // file md5
//    [self writeField:@"rawfilemd5" WithValue:picMD5]; // file md5
//    [self writeField:@"datachecksum" WithValue:[NSString stringWithFormat:@"%ld", aesPicDataAdler32]];

    unsigned long picAdler32 = adler32(0, [picData bytes], (unsigned int) [picData length]);
    [self writeField:@"filecrc" WithValue:[NSString stringWithFormat:@"%ld", picAdler32]]; // adler32 of file
    [self writeField:@"setofpicformat" WithValue:@"001010"];
    [self writeField:@"filedata" WithValue:picData]; //??
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

//   NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"bin"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    CdnSnsUploadTask *snsUploadTask = [CdnSnsUploadTask new];
//    NSDictionary *dic = [snsUploadTask parseResponseToDic:data];
//    LogVerbose(@"%@", dic);
    
//    message CDNUploadMsgImgPrepareRequest {
//    optional  string  clientImgId  = 1;
//    optional  string  fromUserName  = 2;
//    optional  string  toUserName  = 3;
//    required  int32  thumbHeight  = 4;
//    required  int32  thumbWidth  = 5;
//    optional  string  msgSource  = 6;
//    optional  SKBuiltinBuffer_t  clientStat  = 7;
//    optional  int32  scene  = 8;
//    optional  float  longitude  = 9;
//    optional  float  latitude  = 10;
//    optional  string  attachedContent  = 11;
//    optional  string  aeskey  = 16;
//    optional  int32  encryVer  = 17;
//    optional  uint32  crc32  = 18;
//    optional  uint32  msgForwardType  = 19;
//    optional  uint32  source  = 20;
//    optional  string  appid  = 21;
//    optional  string  messageAction  = 22;
//    optional  string  meesageExt  = 23;
//    optional  string  mediaTagName  = 24;

    
//    AccountInfo *accountInfo = [DBManager accountInfo];
//    CDNUploadMsgImgPrepareRequest *request = [CDNUploadMsgImgPrepareRequest new];
//    request.clientImgId = @"rowhongwei56_1576073040";
//    request.fromUserName = accountInfo.userName;
//    request.toUserName = @"wxid_30uhdskklyci22";
//    request.thumbWidth = 100;
//    request.thumbHeight = 100;
//    request.msgSource = @"";
//    request.scene = 0;
//    request.aeskey =
//    request.crc32 =
//    request.msgForwardType = 1;
//    request.source = 20;
//    request.appid = @"";
//    request.messageAction = @"";
//    request.meesageExt = @"";
//    request.mediaTagName = @"";
