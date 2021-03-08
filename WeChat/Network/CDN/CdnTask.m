//
//  CdnTask.m
//  WeChat
//
//  Created by ray on 2020/6/2.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CdnTask.h"
#import "GetCDNDnsService.h"
#import <FastSocket.h>
#import "FSOpenSSL.h"

@interface CdnTask ()

@property (nonatomic, strong) FastSocket *client;
@property (nonatomic, strong, readwrite) NSMutableData *head;
@property (nonatomic, strong, readwrite) NSMutableData *body;
@property (nonatomic, assign, readwrite) NSUInteger seq;

@property (nonatomic, strong) dispatch_queue_t readSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writeSerialQueue;

@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailureBlock failureBlock;

@end

@implementation CdnTask

- (instancetype)initWithSeq:(NSUInteger)seq {
    self = [super init];
    if (self) {
        _head = [NSMutableData data];
        _body = [NSMutableData data];
        _seq = seq;
        _hasPacket = YES;
        
        _readSerialQueue = dispatch_queue_create([[NSString stringWithFormat:@"me.ray.cdn.read-%ld", _seq] UTF8String], DISPATCH_QUEUE_SERIAL);
        _writeSerialQueue = dispatch_queue_create([[NSString stringWithFormat:@"me.ray.cdn.write-%ld", _seq] UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)packBody {
    NSAssert(false, @"must imp in sub class");
}

- (void)packHead {
    NSAssert(false, @"must imp in sub class");
}

- (void)startCdnRequestSuccess:(SuccessBlock)successBlock
                       failure:(FailureBlock)failureBlock {
    
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
    NSString *ip = [self getIp];
    LogVerbose(@"CDN Use Ip: %@", ip);
    FastSocket *client = [[FastSocket alloc] initWithHost:ip andPort:@"443"];
    if ([client connect]) {
        _client = client;
        
        while (self.hasPacket) {
            NSData *data = [self packData];
            [self _sendData:data];
            //clear prev data.
            self.head = [NSMutableData data];
            self.body = [NSMutableData data];
        }
        
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
            if ([dataPackage length] && [dataPackage toInt8ofRange:0] == 0xab)
            {
                NSDictionary *response = [self parseResponseToDic:dataPackage];
                LogVerbose(@"cdn recv response: %@", response);

                // error
                NSInteger retcode = [((NSNumber *)[response objectForKey:@"retcode"]) integerValue];
                if (retcode != 0) {
                    LogVerbose(@"cdn recv response: %@", response);

                    NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:retcode userInfo:@{@"ErrorKey": response}];
                    self.failureBlock(error);
                    [self.client close];
                    break;
                }
                
                // send sns pic
                if ([response objectForKey:@"fileurl"] && [response objectForKey:@"thumburl"] && self.successBlock) {
                    LogVerbose(@"cdn recv response: %@", response);

                    self.successBlock(response);
                    [self.client close];
                    break;
                }
                
                // send msg
                if ([response objectForKey:@"skeybuf"] && self.successBlock) {
                    LogVerbose(@"cdn recv response: %@", response);

                    self.successBlock(response);
                    [self.client close];
                    break;
                }
            }
            else
            {
                LogError(@"no data was read.");
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
        int32_t payloadLength = [header toInt16ofRange:NSMakeRange(3, 2) SwapBigToHost:YES];
        NSData *payloadData = [self readPayload:payloadLength - 5];
        [header appendData:payloadData];

        return [header copy];
    }

    return nil;
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

- (NSData *)packData {
    [self packBody];
    [self packHead];
    
    [self.head appendData:self.body];
    
    return self.head;
}

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
    int32_t vLen = [responseData toInt32ofRange:NSMakeRange(index, 4) SwapBigToHost:YES] & 0xFFFF;
    NSData *valueData = [responseData subdataWithRange:NSMakeRange(index + 4, vLen)]; // 长度有效为低16bit
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

- (NSString *)getIp {
    NSAssert(false, @"must imp in sub class");
    return @"";
}

- (CDNDnsInfo *)getDnsInfo {
    NSAssert(false, @"must imp in sub class");
    return nil;
}

@end
