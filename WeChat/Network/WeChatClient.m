
//  WeChatClient.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LongHeader.h"
#import "LongPackage.h"
#import "ShortPackage.h"

#import "Task.h"
#import "NSData+CompressAndEncypt.h"

#import "ShortLinkClientWithMMTLS.h"

#import "LongLinkClientWithMMTLS.h"
#import "LongLinkClient.h"

#import "header.h"
#import "mmpack.h"
#import "long_pack.h"

#import "UtilsJni.h"

#import "SyncKeyStore.h"
#import "AccountInfo.h"
#import "Cookie.h"
#import "SessionKeyStore.h"

#import "SyncCmdHandler.h"

#import "SyncKeyCompare.h"
#import "MMProtocalJni.h"
#import "Business.h"

#define CMDID_NOOP_REQ 6
#define CMDID_IDENTIFY_REQ 205
#define CMDID_MANUALAUTH_REQ 253

#define CMDID_PUSH_ACK 24
#define CMDID_REPORT_KV_REQ 1000000190

#define HEARTBEAT_SEQ 0xFFFFFFFF
#define IDENTIFY_SEQ 0xFFFFFFFE

@interface WeChatClient () <LongLinkClientWithMMTLSDelegate, LongLinkClientDelegate>

#if USE_MMTLS
@property(nonatomic, strong) LongLinkClientWithMMTLS *client;
#else
@property (nonatomic, strong) LongLinkClient *client;
#endif

@property(nonatomic, strong) NSData *pskData;
@property(nonatomic, strong) NSData *resumptionSecret;

@property(nonatomic, assign) int seq; //封包编号。
@property(nonatomic, strong) NSTimer *heartbeatTimer;

@property(nonatomic, strong) NSMutableArray *tasks;

@property(nonatomic, strong) UtilsJni *Jni;

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

        NSPredicate *accountInfoPre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
        AccountInfo *accountInfo = [[AccountInfo objectsWithPredicate:accountInfoPre] firstObject];
        _uin = accountInfo.uin;

        _tasks = [NSMutableArray array];

#if USE_MMTLS
        _client = [LongLinkClientWithMMTLS new];
#else
        _client = [LongLinkClient new];
#endif
        _client.delegate = self;

        NSPredicate *syncKeyStorePre = [NSPredicate predicateWithFormat:@"ID = %@", SyncKeyStoreID];
        SyncKeyStore *store = [[SyncKeyStore objectsWithPredicate:syncKeyStorePre] firstObject];

        if ([store.data length] > 0) {
            _sync_key_cur = store.data;
            _sync_key_max = store.data;
        } else {
            _sync_key_cur = [NSData data];
            _sync_key_max = [NSData data];
        }

        NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
        Cookie *cookieStore = [[Cookie objectsWithPredicate:cookiePre] firstObject];
        _cookie = cookieStore.data;

        NSPredicate *sessionKeyStorePre = [NSPredicate predicateWithFormat:@"ID = %@", SessionKeyStoreID];
        SessionKeyStore *sessionKeyStore = [[SessionKeyStore objectsWithPredicate:sessionKeyStorePre] firstObject];
        _sessionKey = sessionKeyStore.data;

        _heartbeatTimer = [NSTimer timerWithTimeInterval:70 * 3
                                                  target:self
                                                selector:@selector(heartBeat)
                                                userInfo:nil
                                                 repeats:YES];

        [[NSRunLoop mainRunLoop] addTimer:_heartbeatTimer forMode:NSRunLoopCommonModes];
    }

    return self;
}

- (void)start {
    [_client start];
}

- (void)heartBeat {
    NSData *heart = [long_pack pack:-1 cmdId:CMDID_NOOP_REQ shortData:nil];
    [_client sendData:heart];
}

#pragma mark - Public

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    [[self sharedClient] startRequest:cgiWrap success:successBlock failure:failureBlock];
}

+ (void)postRequest:(CgiWrap *)cgiWrap
            success:(SuccessBlock)successBlock
            failure:(FailureBlock)failureBlock {
    [[self sharedClient] postRequest:cgiWrap success:successBlock failure:failureBlock];
}

+ (void)android700manualAuth:(CgiWrap *)cgiWrap
                     success:(SuccessBlock)successBlock
                     failure:(FailureBlock)failureBlock {
    [[self sharedClient] android700manualAuth:cgiWrap success:successBlock failure:failureBlock];
}

#pragma mark - Internal

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    [self setBaseResquestIfNeed:cgiWrap];

//    LogVerbose(@"Start Request: \n\n%@\n", cgiWrap.request);

    NSData *serilizedData = [[cgiWrap request] data];

    NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
    Cookie *cookie = [[Cookie objectsWithPredicate:cookiePre] firstObject];
    
    int signature = [MMProtocalJni genSignatureWithUin:_uin
                                               ecdhKey:[WeChatClient sharedClient].checkEcdhKey
                                          protofufData:serilizedData];
    
    NSData *shortLinkBuf = [mmpack EncodePack:cgiWrap.cgi
                                serilizedData:serilizedData
                                          uin:_uin
                                       aesKey:[WeChatClient sharedClient].sessionKey
                                       cookie:cookie.data
                                    signature:signature];
    
    NSData *sendData = [long_pack pack:_seq++ cmdId:cgiWrap.cmdId shortData:shortLinkBuf];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    [_client sendData:sendData];
}

- (void)postRequest:(CgiWrap *)cgiWrap
            success:(SuccessBlock)successBlock
            failure:(FailureBlock)failureBlock {

    [self setBaseResquestIfNeed:cgiWrap];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    LogVerbose(@"Start Request: %@", cgiWrap.request);

    NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
    Cookie *cookie = [[Cookie objectsWithPredicate:cookiePre] firstObject];

    NSData *serilizedData = [[cgiWrap request] data];

    int signature = [MMProtocalJni genSignatureWithUin:_uin
                                               ecdhKey:_checkEcdhKey
                                          protofufData:serilizedData];
    
    NSData *sendData = [mmpack EncodePack:cgiWrap.cgi
                            serilizedData:serilizedData
                                      uin:_uin
                                   aesKey:_sessionKey
                                   cookie:cookie.data
                                signature:signature];

#if USE_MMTLS
    NSData *packData = [ShortLinkClientWithMMTLS post:sendData toCgiPath:cgiWrap.cgiPath];
#else
    NSData *packData = [ShortLinkClient post:sendData toCgiPath:cgiWrap.cgiPath];
#endif

    [self UnPack:packData];
}

#pragma mark -

- (void)android700manualAuth:(CgiWrap *)cgiWrap
                     success:(SuccessBlock)successBlock
                     failure:(FailureBlock)failureBlock {

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    NSData *serilizedData = [[cgiWrap request] data];

    UtilsJni *Jni = [UtilsJni new];
    _Jni = Jni;
    
    NSData *HybridEcdhEncryptData = [Jni HybridEcdhEncrypt:serilizedData];

    NSPredicate *accountInfoPre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
    AccountInfo *accountInfo = [[AccountInfo objectsWithPredicate:accountInfoPre] firstObject];
    
    NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
    Cookie *cookie = [[Cookie objectsWithPredicate:cookiePre] firstObject];
    NSData *cookieData = nil;
    if (cookie.data.length) cookieData = cookie.data;
    
    NSData *sendData = [mmpack EncodeHybirdEcdhEncryptPack:cgiWrap.cgi
                                             serilizedData:HybridEcdhEncryptData
                                                       uin:accountInfo.uin
                                                    cookie:cookieData
                                                rsaVersion:10002];

#if USE_MMTLS
    NSData *packData = [ShortLinkClientWithMMTLS post:sendData
                                            toCgiPath:cgiWrap.cgiPath];
#else
    NSData *packData = [ShortLinkClient post:sendData
                                   toCgiPath:cgiWrap.cgiPath];
#endif

    [self UnPack:packData];
}

- (void)setBaseResquestIfNeed:(CgiWrap *)cgiWrap {
    if (cgiWrap.needSetBaseRequest) {
        BaseRequest *base = [BaseRequest new];
        NSData *sessionKey = [WeChatClient sharedClient].sessionKey;
        LogDebug(@"%@", sessionKey);
        [base setSessionKey:sessionKey];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
        AccountInfo *accountInfo = [[AccountInfo objectsWithPredicate:pre] firstObject];
        [base setUin:accountInfo.uin];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:[[DeviceManager sharedManager] getCurrentDevice].osType];
        [base setDeviceId:[[DeviceManager sharedManager] getCurrentDevice].deviceID];
        [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
    }
}

- (void)manualAuth:(CgiWrap *)cgiWrap
           success:(SuccessBlock)successBlock
           failure:(FailureBlock)failureBlock {
    ManualAuthRequest *request = (ManualAuthRequest *) [cgiWrap request];
    ManualAuthRsaReqData *rsaReqData = [request rsaReqData];
    ManualAuthAesReqData *aesReqData = [request aesReqData];

    LogVerbose(@"%@", request);

    NSData *rsaReqDataSerializedData = [rsaReqData data];
    NSData *aesReqDataSerializedData = [aesReqData data];

    NSData *reqAccount = [rsaReqDataSerializedData Compress_And_RSA];
    NSData *reqDevice = [aesReqDataSerializedData Compress_And_AES];

    NSMutableData *subHeader = [NSMutableData data];
    [subHeader appendData:[NSData packInt32:(int32_t) [rsaReqDataSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t) [aesReqDataSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t) [reqAccount length] flip:YES]];

    NSMutableData *body = [NSMutableData dataWithData:subHeader];
    [body appendData:reqAccount];
    [body appendData:reqDevice];

    NSData *head = [header make_header:cgiWrap.cgi
                         encryptMethod:RSA
                              bodyData:body
                    compressedBodyData:body
                            needCookie:NO
                                cookie:nil
                                   uin:_uin];

    NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
    [longlinkBody appendData:body];

    NSData *sendData = [long_pack pack:_seq++ cmdId:cgiWrap.cmdId shortData:longlinkBody];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    [_client sendData:sendData];
}

- (void)registerWeChat:(CgiWrap *)cgiWrap
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock {
    [self setBaseResquestIfNeed:cgiWrap];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    LogVerbose(@"Start Request: %@", cgiWrap.request);

    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [mmpack pack:cgiWrap.cgi
                          serilizedData:serilizedData
                                   type:1
                                    uin:0
                                 cookie:nil];

#if USE_MMTLS
    NSData *packData = [ShortLinkClientWithMMTLS post:sendData toCgiPath:cgiWrap.cgiPath];
#else
    NSData *packData = [ShortLinkClient post:sendData toCgiPath:cgiWrap.cgiPath];
#endif

    [self UnPack:packData];
}

- (void)autoAuth:(CgiWrap *)cgiWrap
         success:(SuccessBlock)successBlock
         failure:(FailureBlock)failureBlock {
    ManualAuthRequest *request = (ManualAuthRequest *) [cgiWrap request];
    ManualAuthRsaReqData *rsaReqData = [request rsaReqData];
    ManualAuthAesReqData *aesReqData = [request aesReqData];

    NSData *rsaReqDataSerializedData = [rsaReqData data];
    NSData *aesReqDataSerializedData = [aesReqData data];

    NSData *reqAccount = [rsaReqDataSerializedData Compress_And_RSA];
    NSData *authAesData = [rsaReqDataSerializedData Compress_And_AES];
    NSData *reqDevice = [aesReqDataSerializedData Compress_And_AES];

    NSMutableData *subHeader = [NSMutableData data];
    [subHeader appendData:[NSData packInt32:(int32_t) [rsaReqDataSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t) [aesReqDataSerializedData length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t) [reqAccount length] flip:YES]];
    [subHeader appendData:[NSData packInt32:(int32_t) [authAesData length] flip:YES]];

    NSMutableData *body = [NSMutableData dataWithData:subHeader];
    [body appendData:reqAccount];
    [body appendData:authAesData];
    [body appendData:reqDevice];

    NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
    Cookie *cookie = [[Cookie objectsWithPredicate:cookiePre] firstObject];

    NSData *head = [header make_header2:cgiWrap.cgi
                          encryptMethod:AUTOAUTH
                               bodyData:body
                     compressedBodyData:body
                             needCookie:YES
                                 cookie:cookie.data
                                    uin:_uin];

    NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
    [longlinkBody appendData:body];

    NSData *sendData = [long_pack pack:_seq++ cmdId:cgiWrap.cmdId shortData:longlinkBody];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    [_client sendData:sendData];
}

#pragma mark - Pack

- (Task *)getTaskWithTag:(NSInteger)tag {
    Task *result = nil;
    for (int i = 0; i < [_tasks count]; i++) {
        Task *task = [_tasks objectAtIndex:i];
        if (task.cgiWrap.cgi == tag) {
            result = task;
        }
    }

    return result;
}

- (void)UnPack:(NSData *)data {
    ShortPackage *package = [mmpack DecodePack:data];
    NSData *sessionKey = [WeChatClient sharedClient].sessionKey;
    NSData *protobufData = nil;

    Task *task = [self getTaskWithTag:package.header.cgi];

    if (package.header.cgi == 252 || package.header.cgi == 763) {
        protobufData = [_Jni HybridEcdhDecrypt:package.body];
        
//        [_client restart];
//        [self heartBeat];
        
        if ([self.sync_key_cur length] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [Business newInitWithSyncKeyCur:self.sync_key_cur syncKeyMax:self.sync_key_max];
            });
        } else {
            [Business newSync];
        }
    } else {
        protobufData = package.header.compressed ? [package.body aesDecrypt_then_decompress] : [package.body aesDecryptWithKey:sessionKey];
    }

    NSError *error = nil;
    id response = [[task.cgiWrap.responseClass alloc] initWithData:protobufData error:&error];
    if (error) {
        LogError("ProtoBuf Serilized Error: %@", error);
        if (task.failBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ((FailureBlock) task.failBlock)(error);
            });
            [_tasks removeObject:task];
        }
    } else if (task.sucBlock && response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((SuccessBlock) task.sucBlock)(response);
        });
        [_tasks removeObject:task];
    }
}

- (void)onLongLinkHandShakeFinishedWithPSK:(NSData *)pskData
                          resumptionSecret:(NSData *)resumptionSecret {
    _pskData = pskData;
    _resumptionSecret = resumptionSecret;
}

- (void)onRecivceLongLinkPlainData:(NSData *)plainData {
    LongPackage *longLinkPackage = [long_pack unpack:plainData];

    switch (longLinkPackage.result) {
        case UnPack_Success: {
            LogVerbose(@"Receive CmdID: %d, SEQ: %d, BodyLen: %d",
                    longLinkPackage.header.cmdId,
                    longLinkPackage.header.seq,
                    longLinkPackage.header.bodyLength);

            if (longLinkPackage.header.bodyLength < 0x20) {
                switch (longLinkPackage.header.cmdId) {
                    case CMDID_PUSH_ACK: {
                        if ([self.sync_key_cur length] == 0) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [Business newInitWithSyncKeyCur:self.sync_key_cur syncKeyMax:self.sync_key_max];
                            });
                        } else {
                            [Business newSync];
                        }
                        break;
                    }
                    default:
                        break;
                }
            } else {
                [self UnPack:longLinkPackage.body];
            }
        }
            break;
        case UnPack_Continue: {
        }
            break;
        default:
            break;
    }
}

@end
