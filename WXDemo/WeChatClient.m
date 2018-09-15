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

@property (nonatomic, strong) NSData * aesKey;
@property (nonatomic, assign) int uin;
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
        _aesKey = [FSOpenSSL random128BitAESKey];
        
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
    [_socket connectToHost:@"long.weixin.qq.com" onPort:80 error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self heartBeat];
    
    [self test];
}

- (void)test {
    NSData *header = [self make_header:502 encryptMethod:NONE bodyDataLen:125 compressedBodyDataLen:125 needCookie:false];
    NSLog(@"header: %@", header);
}

- (void)heartBeat {
    NSData *data = [self longlink_packWithSeq:_seq cmdId:CMDID_NOOP_REQ buffer:nil];
    [_socket writeData:data withTimeout:HEARTBEAT_TIMEOUT tag:CMDID_NOOP_REQ];
}

+ (void)startRequest:(CgiWrap *)request
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    [[self sharedClient] startRequest:request success:successBlock failure:failureBlock];
}

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    
    BaseRequest *base = [BaseRequest new];
    [base setUin:0];
    [base setScene:0];
    [base setClientVersion:CLIENT_VERSION];
    [base setDeviceType:DEVICE_TYPE];
    [base setSessionKey:_aesKey];
    [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
    
    [[cgiWrap request] performSelector:@selector(setBase:) withObject:base];
    
    NSData *serilizedData = [[cgiWrap request] data];
    
    NSLog(@"protobuf: %@", serilizedData);
    
    NSData *sendData = [self pack:[cgiWrap cmdId] cgi:[cgiWrap cgi] serilizedData:serilizedData type:1];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    
    [_tasks addObject:task];
    [_socket writeData:sendData withTimeout:3 tag:[cgiWrap cmdId]];
}

- (Task *)getTaskWithTag:(NSInteger)tag {
    Task *result = nil;
    for (int i=0; i<[_tasks count]; i++) {
        Task *task = [_tasks objectAtIndex:i];
        if (task.cgiWrap.cmdId == tag) {
            result = task;
        }
    }
    
    return result;
}

#pragma mark - Delegate

/**
* This method is called immediately prior to socket:didAcceptNewSocket:.
* It optionally allows a listening socket to specify the socketQueue for a new accepted socket.
* If this method is not implemented, or returns NULL, the new accepted socket will create its own default queue.
*
* Since you cannot autorelease a dispatch_queue,
* this method uses the "new" prefix in its name to specify that the returned queue has been retained.
*
* Thus you could do something like this in the implementation:
* return dispatch_queue_create("MyQueue", NULL);
*
* If you are placing multiple sockets on the same queue,
* then care should be taken to increment the retain count each time this method is invoked.
*
* For example, your implementation might look something like this:
* dispatch_retain(myExistingQueue);
* return myExistingQueue;
**/
//- (nullable dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock {
//
//}

/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 *
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 *
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"comnect %@:%d", host, port);
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData: %@, cgi: %ld",data, tag);
    
    [_recvedData appendData:data];
    
    LongLinkPackage *longLinkPackage = [LongLinkPackage new];
    UnPackResult result = [self unPackLongLink:_recvedData toLongLingPackage:longLinkPackage];
    
    switch (result) {
        case UnPack_Success: {
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
                
                NSData *protobufData = package.header.compressed ? [package.body aesDecrypt_then_decompress] : [package.body aesDecrypt];
                Task *task = [self getTaskWithTag:tag];
                id response = [[task.cgiWrap.responseClass alloc] initWithData:protobufData error:nil];
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
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {

}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag: %ld", tag);
    [_socket readDataWithTimeout:3 tag:tag];
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    
}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length {
//
//}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length {
//
//}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    
}

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 *
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
 **/
- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    
}

/**
 * Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if startTLS is invoked with options that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * Thus this method uses a completionHandler block rather than a normal return value.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    
}

#pragma mark - Pack

- (UnPackResult)unPackLongLink:(NSData *)recvdRawData toLongLingPackage:(LongLinkPackage *)longLinkPackage {
    if ([recvdRawData length] < 16) {// 包头不完整。
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
        NSLog(@"Should Contine Read Data");
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
            NSData *head = [self make_header:cgi encryptMethod:NONE bodyDataLen:(int)[serilizedData length] compressedBodyDataLen:(int)[serilizedData length] needCookie:NO];
            NSData *modules = [NSData dataWithHexString:LOGIN_RSA_VER172_KEY_N];
            NSData *expoent = [NSData dataWithHexString:LOGIN_RSA_VER172_KEY_E];
            NSData *body = [FSOpenSSL RSAEncryptString:serilizedData modulus:modules exponent:expoent];
            NSMutableData *d = [[NSMutableData alloc] init];
            [d appendData:head];
            [d appendData:body];
            sendData = [self longlink_packWithSeq:self.seq++ cmdId:cmdId buffer:[d copy]];
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
        NSString *cookieString = [[NSString alloc] initWithData:cookie encoding:NSUTF8StringEncoding];
        NSLog(@"Cookie: %@", cookieString);
        index += cookieLen;
    } else if (cookieLen > 0xf) {
        return nil;
    }
    
    int cgi = 0;
    int dwLen = [self decode:&cgi bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
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

- (NSData *)make_header:(int)cgi encryptMethod:(EncryptMethod)encryptMethod bodyDataLen:(int)bodyDataLen compressedBodyDataLen:(int)compressedBodyDataLen needCookie:(BOOL)needCookie {
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
    
    [header appendData:[NSData varintBytes:cgi]];
    [header appendData:[NSData varintBytes:bodyDataLen]];
    [header appendData:[NSData varintBytes:compressedBodyDataLen]];
    
    if (need_login_rsa_verison(cgi)) {
        [header appendData:[NSData varintBytes:LOGIN_RSA_VER_172]];
        [header appendData:[NSData dataWithHexString:@"0D00"]];
        [header appendData:[NSData packInt16:9 flip:NO]];
    } else {
        [header appendData:[NSData dataWithHexString:@"000D"]];
        [header appendData:[NSData packInt16:9 flip:NO]];   //need fix
    }
    
    [header replaceBytesInRange:NSMakeRange(1, 1) withBytes:[[NSData varintBytes:(int)(([header length] << 2) + 0x2)] bytes]];
    return [header copy];
}

bool need_login_rsa_verison(int cgi) {
    return cgi == 502 || cgi == 503 || cgi == 701;
}

@end
