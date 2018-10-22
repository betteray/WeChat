//
//  WeChatClient.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WeChatClient.h"
#import "GCDAsyncSocket.h" // for TCP
#import "NSData+Util.h"
#import "Constants.h"
#import "FSOpenSSL.h"
#import "LongLinkHeader.h"
#import "LongLinkPackage.h"
#import "Package.h"
#import "Mm.pbobjc.h"
#import "CgiWrap.h"
#import "Task.h"
#import "NSData+PackUtil.h"
#import "MarsOpenSSL.h"
#import "NSData+CompressAndEncypt.h"
#import "NSData+Compression.h"
#import "NSData+GenRandomData.h"
#import <YYModel/YYModel.h>
#import "Varint128.h"
#import "NSData+Compress.h"

//#心跳
#define CMDID_NOOP_REQ 6
//#长链接确认
#define CMDID_IDENTIFY_REQ 205
//#登录
#define CMDID_MANUALAUTH_REQ = 253
//#推送通知
#define CMDID_PUSH_ACK = 24
//#通知服务器消息已接收
#define CMDID_REPORT_KV_REQ = 1000000190


//#心跳包seq id
#define HEARTBEAT_SEQ 0xFFFFFFFF
//#长链接确认包seq id
#define IDENTIFY_SEQ 0xFFFFFFFE

#define HEARTBEAT_TIMEOUT 60

#define HANDSHAKE_CLIENT_HELLO 22

typedef NS_ENUM(int, EncryptMethod) {
    NONE = 0x1,
    AES = 0x5,
    RSA = 0x7,
};

typedef NS_ENUM(NSInteger, UnPackResult) {
    UnPack_Fail,
    UnPack_Continue,
    UnPack_Success
};

@interface WeChatClient()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableData *recvedData;
@property (nonatomic, assign) int seq;    //封包编号。
@property (nonatomic, strong) NSTimer *heartbeatTimer;

@property (nonatomic, strong) NSData *cookie;

@property (nonatomic, strong) NSMutableArray *tasks;

@end

@implementation WeChatClient

+ (instancetype)sharedClient {
    static WeChatClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[WeChatClient alloc] init];
    });
    return _client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _seq = 1;
        _uin = 0;
        _tasks = [NSMutableArray array];
        _recvedData = [NSMutableData data];
//        _sessionKey = [FSOpenSSL random128BitAESKey]; // iPad
        _sessionKey = [NSData GenRandomDataWithSize:184]; //iMac

        NSString *priKey = nil;
        NSString *pubKey = nil;
        if ([MarsOpenSSL genRSAKeyPairPubKey:&pubKey priKey:&priKey]) {
            _priKey = [priKey dataUsingEncoding:NSUTF8StringEncoding];
            _pubKey = [pubKey dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            NSLog(@" ** Gen RSA KeyPair Fail. ** ");
        }
        
        _heartbeatTimer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_heartbeatTimer forMode:NSRunLoopCommonModes];
        
        GCDAsyncSocket *s = [[GCDAsyncSocket alloc] init];
        [s setDelegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [s setDelegate:self];
        _socket = s;
    }
    
    return self;
}

- (void)start {
    NSError *error;
    [_socket connectToHost:@"long.weixin.qq.com" onPort:443 error:&error];
    if (error) {
        NSLog(@"Socks Start Error: %@", [error localizedDescription]);
    }
    [self DoSendClientHello];
}

- (void)DoSendClientHello {
    NSData *clientHelloData = [self CreateClientHello];
    [_socket writeData:clientHelloData withTimeout:HEARTBEAT_TIMEOUT tag:HANDSHAKE_CLIENT_HELLO];
}

- (NSData *)CreateClientHello {
    NSMutableData *clientHelloData = [[NSData dataWithHexString:@"16F10300D4000000D00103F101C02B"] mutableCopy];
    [clientHelloData appendData:[NSData GenRandomDataWithSize:32]];
    
    NSUInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    [clientHelloData appendData:[NSData packInt32:(int32_t)timeStamp flip:NO]]; //time
    [clientHelloData appendData:[NSData dataWithHexString:@"000000A2010000009D00100200000047000000010041"]]; //fix
    [clientHelloData appendData:[NSData dataWithHexString:@"04BDB8F1450D9B8DDF82954E5CB7ADE728DD39E0B927278E69163D52799A2E1B33CEF36E503B34414F5EFEC0DBD5B810A56B9FA742BB0A5557BFB51D7215094DFD"]]; //pubkey
    [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000020041"]]; //fix
    [clientHelloData appendData:[NSData dataWithHexString:@"04EA4902EDC416E107805E5D72191814F132E44221969EF3E8F900321BD5DDBBEBA1CF0169E6ECDE4B04BA33401F586DDB9C57C37A28D5AFEA9669F166B44B90F3"]]; //pubkey
    [clientHelloData appendData:[NSData dataWithHexString:@"00000001"]]; //fix
    
    return [clientHelloData copy];
}

- (void)restartUsingIpAddress:(NSString *)IpAddress {
    [_socket disconnect];
    
    NSError *error;
    [_socket connectToHost:IpAddress onPort:80 error:&error];
    if (error) {
        NSLog(@"Socks ReStart Error: %@", [error localizedDescription]);
        return ;
    }
    [self heartBeat];
}

- (void)test {
//    NSData *header = [self make_header:502 encryptMethod:NONE bodyData:125 compressedBodyData:125 needCookie:false];
//    NSLog(@"header: %@", header);
}

- (void)heartBeat {
    NSData *data = [self longlink_packWithSeq:_seq cmdId:CMDID_NOOP_REQ buffer:nil];
    [_socket writeData:data withTimeout:HEARTBEAT_TIMEOUT tag:CMDID_NOOP_REQ];
}

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    [[self sharedClient] startRequest:cgiWrap success:successBlock failure:failureBlock];
}

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    
    BaseRequest *base = [BaseRequest new];
    [base setSessionKey:[NSData data]];
    [base setUin:0];
    [base setScene:1]; // iMac 1
    [base setClientVersion:CLIENT_VERSION];
    [base setDeviceType:DEVICE_TYPE];
    [base setSessionKey:[NSData data]];
    [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
    
    [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
    
    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [self pack:[cgiWrap cmdId] cgi:[cgiWrap cgi] serilizedData:serilizedData type:1];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
    
    [_socket writeData:sendData withTimeout:3 tag:[cgiWrap cgi]];
}

- (void)manualAuth:(CgiWrap *)cgiWrap
           success:(SuccessBlock)successBlock
           failure:(FailureBlock)failureBlock {
    ManualAuthRequest *request = (ManualAuthRequest *)[cgiWrap request];
    ManualAuthAccountRequest *accountRequest = [request rsaReqData];
    ManualAuthDeviceRequest *deviceRequest = [request aesReqData];

    BaseRequest *base = [BaseRequest new];
    [base setUin:0];
    [base setScene:0];
    [base setClientVersion:CLIENT_VERSION];
    [base setDeviceType:DEVICE_TYPE];
    [base setSessionKey:[NSData data]];
    [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
    
    [deviceRequest setBaseRequest:base];
    
    NSLog(@"%@", [[cgiWrap request] yy_modelToJSONString]);
    
    NSData *accountSerializedData = [accountRequest data];
    NSData *deviceSerializedData = [deviceRequest data];
    
    NSData *reqAccount = [accountSerializedData Compress_And_RSA];
    NSData *reqDevice = [deviceSerializedData Compress_And_AES];
    
    NSMutableData *subHeader = [NSMutableData data];
    [subHeader appendData:[NSData packInt32:(int32_t)[accountSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t)[deviceSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t)[reqAccount length] flip:YES]];
    
    NSMutableData *body = [NSMutableData dataWithData:subHeader];
    [body appendData:reqAccount];
    [body appendData:reqDevice];
    
    NSData *head = [self make_header:cgiWrap.cgi encryptMethod:RSA bodyData:body compressedBodyData:body needCookie:NO];
    
    NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
    [longlinkBody appendData:body];
    
    NSData *sendData = [self longlink_packWithSeq:self.seq++ cmdId:cgiWrap.cmdId buffer:longlinkBody];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
    
    [_socket writeData:sendData withTimeout:3 tag:[cgiWrap cgi]];
}

- (void)sendMsg:(CgiWrap *)cgiWrap
        success:(SuccessBlock)successBlock
        failure:(FailureBlock)failureBlock {
    
    id request = cgiWrap.request;
    
    NSLog(@"sendMsg: %@", request);
    
    NSData *serializedData = [request data];
//    NSData *sendData = [self pack:cgiWrap.cmdId cgi:cgiWrap.cgi serilizedData:serializedData type:5];
    NSData *head = [self make_header:cgiWrap.cgi encryptMethod:AES bodyData:serializedData compressedBodyData:serializedData needCookie:YES];
    NSData *body = [serializedData AES];

    NSMutableData *sendData = [NSMutableData dataWithData:head];
    [sendData appendData:body];
    sendData = [[sendData subdataWithRange:NSMakeRange(2, [sendData length] - 1 - 2)] mutableCopy];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
    
//    NSURL *nsurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", _shortLinkUrl]];
//    NSMutableURLRequest *http_request = [NSMutableURLRequest requestWithURL:nsurl];
//    http_request.HTTPMethod = @"POST";
//    [http_request setValue:@"Accept" forHTTPHeaderField:@"*/*"];//token
//    [http_request setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];//坐标 lng
//    [http_request setValue:@"Connection" forHTTPHeaderField:@"close"];//坐标 lat
//    [http_request setValue:@"Content-type" forHTTPHeaderField:@"application/octet-stream"];//版本
//    [http_request setValue:@"User-Agent" forHTTPHeaderField:@"MicroMessenger Client"];//版本
//    [http_request setHTTPBody:[sendData copy]];
//
//    NSLog(@"POST-Header:%@",http_request.allHTTPHeaderFields);
//
//    NSURLSessionTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:http_request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@", data);
//    }];
//
//    [dataTask resume];
    
    [_socket writeData:sendData withTimeout:3 tag:cgiWrap.cgi];
}

- (Task *)getTaskWithTag:(NSInteger)tag {
    Task *result = nil;
    for (int i=0; i<[_tasks count]; i++) {
        Task *task = [_tasks objectAtIndex:i];
        if (task.cgiWrap.cgi == tag) {
            result = task;
        }
    }
    
    return result;
}

#pragma mark - Delegate

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost %@:%d", host, port);
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    NSLog(@"didConnectToUrl %@", url);
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@">>> didReadData: %@, cgi: %ld",data, tag);
    
    [_recvedData appendData:data];
    
    LongLinkPackage *longLinkPackage = [LongLinkPackage new];
    UnPackResult result = [self unPackLongLink:_recvedData toLongLingPackage:longLinkPackage];
    
    switch (result) {
        case UnPack_Success: {
            NSLog(@">>> LongLinkPackage Head CmdId: %d", longLinkPackage.header.cmdId);
            [_recvedData setData:[NSData new]];//清空数据。
            
            if (longLinkPackage.header.bodyLength < 0x20) {
                switch (longLinkPackage.header.cmdId) {
                    case 1:
                        break;
                    default:
                        break;
                }
            } else {
                Package *package = [self UnPackLongLinkBody:longLinkPackage.body];
                NSData *protobufData = package.header.compressed ? [package.body aesDecrypt_then_decompress] : [package.body aesDecryptWithKey:_sessionKey];
                Task *task = [self getTaskWithTag:package.header.cgi];
                id response = [[task.cgiWrap.responseClass alloc] initWithData:protobufData error:nil];
                NSLog(@"WeChatClient Response: %@", response);
                if (task.sucBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ((SuccessBlock)task.sucBlock)(response);
                    });
                    [_tasks removeObject:task];
                }
            }
        }
            break;
        case UnPack_Continue: {
            [_socket readDataWithTimeout:3 tag:tag];
        }
            break;
        default:
            [_recvedData setData:[NSData new]];//清空数据。
            break;
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"<<< didWriteDataWithTag: %ld", tag);
    [_socket readDataWithTimeout:3 tag:tag];
}

#pragma mark - Pack

- (UnPackResult)unPackLongLink:(NSData *)recvdRawData toLongLingPackage:(LongLinkPackage *)longLinkPackage {
    if ([recvdRawData length] < 16) {// 包头不完整。
        NSLog(@"Should Contine Read Data: 包头不完整");
        return UnPack_Continue;
    }
    
    LongLinkHeader *header = [LongLinkHeader new];
    
    header.bodyLength = [recvdRawData toInt32ofRange:NSMakeRange(0, 4) SwapBigToHost:YES];
    header.headLength = [recvdRawData toInt16ofRange:NSMakeRange(4, 2) SwapBigToHost:NO] >> 8;
    header.clientVersion = [recvdRawData toInt16ofRange:NSMakeRange(6, 2) SwapBigToHost:NO] >> 8;
    header.cmdId = [recvdRawData toInt32ofRange:NSMakeRange(8, 4) SwapBigToHost:YES];
    header.seq = [recvdRawData toInt32ofRange:NSMakeRange(12, 4) SwapBigToHost:YES];
    if (header.bodyLength > [recvdRawData length]) {
        //包未收完。
        NSLog(@"Should Contine Read Data: 包未收完。");
        return UnPack_Continue;
    }
    
    longLinkPackage.header = header;
    longLinkPackage.body = [recvdRawData subdataWithRange:NSMakeRange(16, [recvdRawData length] - 16)];
    
    return UnPack_Success;
}

- (NSData *)pack:(int)cmdId cgi:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type {
    NSData *sendData = nil;
    switch (type) {
        case 7:{
            
        }
            break;
        case 1: {
            NSData *head = [self make_header:cgi encryptMethod:NONE bodyData:serilizedData compressedBodyData:serilizedData needCookie:NO];
            NSData *body = [MarsOpenSSL RSA_PUB_EncryptData:serilizedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];
            sendData = [self longlink_packWithSeq:self.seq++ cmdId:cmdId buffer:[longlinkBody copy]];
        }
            break;
        case 5: {
            NSData *compressedData = [serilizedData compresss];
            NSData *head = [self make_header:cgi encryptMethod:AES bodyData:serilizedData compressedBodyData:compressedData needCookie:YES];
            NSData *body = [compressedData AES];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];
            sendData = [self longlink_packWithSeq:self.seq++ cmdId:cmdId buffer:[longlinkBody copy]];
        }
            break;
        default:
            break;
    }
    
    return sendData;
}

#pragma mark - longlink pack

- (NSData *)longlink_packWithSeq:(int)seq cmdId:(int)cmdId buffer:(NSData *)buffer {
    
    NSMutableData *longlink_header = [NSMutableData data];
    
    [longlink_header appendData:[NSData packInt32:(int)([buffer length] + 16) flip:YES]];
    [longlink_header appendData:[NSData dataWithHexString:@"0010"]];
    [longlink_header appendData:[NSData dataWithHexString:@"0001"]];
    [longlink_header appendData:[NSData packInt32:cmdId flip:YES]];
    
    if (cmdId == CMDID_NOOP_REQ) {
        [longlink_header appendData:[NSData packInt32:HEARTBEAT_SEQ flip:YES]];
    } else if (CMDID_IDENTIFY_REQ == cmdId) {
        [longlink_header appendData:[NSData packInt32:IDENTIFY_SEQ flip:YES]];
    } else {
        [longlink_header appendData:[NSData packInt32:seq flip:YES]];
    }
    
    [longlink_header appendData:buffer];
    return [longlink_header copy];
}


#pragma mark - make header

- (int)decode:(int *)apuValue bytes:(NSData *)apcBuffer off:(int)off {
    int num3;
    int num = 0;
    int num2 = 0;
    int num4 = 0;
    int num5 = *(int*)[[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    while ((num5 & 0xff) >= 0x80)
    {
        num3 = num5 & 0x7f;
        num4 += num3 << num2;
        num2 += 7;
        num5 = *(int*)[[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    }
    num3 = num5;
    num4 += num3 << num2;
    *apuValue = num4;
    return num;
}

- (Package *)UnPackLongLinkBody:(NSData *)body {
    Package *package = [Package new];
    Header *header = [Header new];
    package.header = header;
    if ([body length] < 0x20) return nil;
    
    NSInteger index = 0;
    int mark = (int)[body toInt8ofRange:index];
    if (mark == 0xbf) {
        index ++;
    }
    int32_t headLength = (int)[body toInt8ofRange:index] >> 2;
    header.compressed = (1 == ((int)[body toInt8ofRange:index] & 0x3));
    index ++;

    header.decrytType = (int)[body toInt8ofRange:index] >> 4;
    int cookieLen = (int)[body toInt8ofRange:index] & 0xf;
    index ++;
    index += 4; //服务器版本，忽略。
    
    _uin = (int)[body toInt8ofRange:index];
    index += 4;
    
    if (cookieLen > 0 && cookieLen <=0xf) {
        NSData *cookie = [body subdataWithRange:NSMakeRange(index, cookieLen)];
        NSLog(@"Cookie: %@", cookie);
        index += cookieLen;
        _cookie = cookie;
    } else if (cookieLen > 0xf) {
        return nil;
    }
    
    int cgi = 0;
    int dwLen = [self decode:&cgi bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    header.cgi = cgi;
    index += dwLen;
    
    int protobufLen = 0;
    dwLen = [self decode:&protobufLen bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    index += dwLen;
    
    int compressedLen = 0;
    dwLen = [self decode:&compressedLen bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    //后面的数据无视。
    
    //解包完毕，取包体。
    
    if (headLength < [body length]) {
        package.body = [body subdataWithRange:NSMakeRange(headLength, [body length] - headLength)];
    }
    
    return package;
}

- (NSData *)make_header:(int)cgi encryptMethod:(EncryptMethod)encryptMethod bodyData:(NSData *)bodyData compressedBodyData:(NSData *)compressedBodyData needCookie:(BOOL)needCookie {
    
    int bodyDataLen = (int)[bodyData length];
    int compressedBodyDataLen = (int)[compressedBodyData length];

    NSMutableData *header = [NSMutableData data];
    
    [header appendData:[NSData dataWithHexString:@"BF"]];//
    [header appendData:[NSData dataWithHexString:@"00"]];//包头长度，最后计算。
    int len = (encryptMethod << 4) + (needCookie ? 0xf : 0x0);
    [header appendData:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", len]]];
    [header appendData:[NSData packInt32:CLIENT_VERSION flip:YES]];
    [header appendData:[NSData packInt32:_uin flip:YES]];
    
    if (needCookie) {
        if ([_cookie length] < 0xf) {
            [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
        } else {
            [header appendData:_cookie];
        }
    }
    
    [header appendData:[Varint128 dataWithUInt32:cgi]];
    [header appendData:[Varint128 dataWithUInt32:bodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:compressedBodyDataLen]];
    
    if (_checkEcdhKey.length > 0) {
        [header appendData:[self ecdhCheck:bodyData]];
    }
    
    if (need_login_rsa_verison(cgi)) {
        [header appendData:[Varint128 dataWithUInt32:LOGIN_RSA_VER_172]];
        [header appendData:[NSData dataWithHexString:@"0D00"]];
        [header appendData:[NSData packInt16:9 flip:NO]];
    } else {
        [header appendData:[NSData dataWithHexString:@"000D"]];
        [header appendData:[NSData packInt16:(9 * (1 & 7)) flip:NO]];   //need fix
    }
    
    [header replaceBytesInRange:NSMakeRange(1, 1) withBytes:[[Varint128 dataWithUInt32:(int)(([header length] << 2) + 0x2)] bytes]];
    return [header copy];
}

- (NSData *)ecdhCheck:(NSData *)buff {
    NSData *data = [buff dataByDeflating];
    return [FSOpenSSL aesEncryptData:data key:_checkEcdhKey];
}

bool need_login_rsa_verison(int cgi) {
    return cgi == 502 || cgi == 503 || cgi == 701;
}

@end
