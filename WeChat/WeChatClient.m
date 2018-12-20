
//  WeChatClient.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WeChatClient.h"
#import "NSData+Util.h"

#import "FSOpenSSL.h"

#import "LongHeader.h"
#import "LongPackage.h"
#import "ShortPackage.h"

#import "Mm.pbobjc.h"
#import "CgiWrap.h"
#import "Task.h"
#import "NSData+PackUtil.h"
#import "NSData+CompressAndEncypt.h"
#import "NSData+Compression.h"
#import "NSData+GenRandomData.h"
#import <YYModel/YYModel.h>
#import "Varint128.h"

#import "MMTLSShortLinkResponse.h"
#import "ShortLinkWithMMTLS.h"
#import "ShortLinkClient.h"

#import "LongLinkClient.h"

#import "header.h"
#import "short_pack.h"
#import "long_pack.h"

#define CMDID_NOOP_REQ 6
#define CMDID_IDENTIFY_REQ 205
#define CMDID_MANUALAUTH_REQ 253

#define CMDID_PUSH_ACK 24
#define CMDID_REPORT_KV_REQ 1000000190

#define HEARTBEAT_SEQ 0xFFFFFFFF
#define IDENTIFY_SEQ 0xFFFFFFFE

@interface WeChatClient () <LongLinkClientDelegate>

@property (nonatomic, strong) LongLinkClient *mmtlsClient;

@property (nonatomic, assign) int seq; //封包编号。
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) NSData *cookie;
@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) NSData *sync_key_cur;
@property (nonatomic, strong) NSData *sync_key_max;

@end

@implementation WeChatClient

+ (instancetype)sharedClient
{
    static WeChatClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[WeChatClient alloc] init];
    });
    return _client;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _seq = 1;
        _uin = 0;
        
        _tasks = [NSMutableArray array];

        [[DBManager sharedManager] saveSessionKey:[FSOpenSSL random128BitAESKey]];      // iPad
        //[[DBManager sharedManager] saveSessionKey:[NSData GenRandomDataWithSize:184]];  // iMac

        _mmtlsClient = [LongLinkClient new];
        _mmtlsClient.delegate = self;
        
        _sync_key_cur = [NSData data];
        _sync_key_max = [NSData data];

        NSString *priKey = nil;
        NSString *pubKey = nil;
        if ([FSOpenSSL genRSAKeyPairPubKey:&pubKey priKey:&priKey])
        {
            _priKey = [priKey dataUsingEncoding:NSUTF8StringEncoding];
            _pubKey = [pubKey dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            LogError(@" ** Gen RSA KeyPair Fail. ** ");
        }

        _heartbeatTimer = [NSTimer timerWithTimeInterval:60 * 3 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_heartbeatTimer forMode:NSRunLoopCommonModes];

    }

    return self;
}

- (void)start
{
    [_mmtlsClient start];
}


#pragma mark - Clinet Misc

- (void)newInitWithSyncKeyCur:(NSData *)syncKeyCur syncKeyMax:(NSData *)syncKeyMax
{
    NewInitRequest *request = [NewInitRequest new];
    request.userName = [WXUserDefault getWXID];
    request.currentSynckey = syncKeyCur;
    request.maxSynckey = syncKeyMax;
    request.language = LANGUAGE;

    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 139;
    wrap.cmdId = 27;
    wrap.request = request;
    wrap.cgiPath = @"/cgi-bin/micromsg-bin/newinit";
    wrap.responseClass = [NewInitResponse class];

    [[WeChatClient sharedClient] startRequest:wrap
        success:^(NewInitResponse *_Nullable response) {
            self.sync_key_cur = response.syncKeyCur;
            self.sync_key_max = response.syncKeyMax;

            LogInfo(@"sync key cur: %@", self.sync_key_cur);
            LogInfo(@"sync key max: %@", self.sync_key_max);

            LogVerbose(@"newinit cmd count: %d, continue flag: %d", response.cntList, response.continueFlag);

            for (int i = 0; i < response.cntList; i++)
            {
                common_msg *cmsg = [response.tag7Array objectAtIndex:i];
                if (5 == cmsg.type)
                {
                    Msg *msg = [[Msg alloc] initWithData:cmsg.data_p.data_p error:nil];
                    if (10002 == msg.type || 9999 == msg.type)
                    { //系统消息
                        continue;
                    }
                    else
                    {
                        LogVerbose(@"Serverid: %lld, CreateTime: %d, WXID: %@, TOID: %@, Type: %d, Raw Content: %@", msg.serverid, msg.createTime, msg.fromId.string, msg.toId.string, msg.type, msg.raw.content);
                    }
                }
                else if (2 == cmsg.type) //好友列表
                {
                    contact_info *cinfo = [[contact_info alloc] initWithData:cmsg.data_p.data_p error:nil];
                    LogVerbose(@"update contact: Relation[%@], WXID: %@, Alias: %@", (cinfo.type & 1) ? @"好友" : @"非好友", cinfo.wxid.string, cinfo.alias);
                }
            }

            if (response.continueFlag)
            {
                [self newInitWithSyncKeyCur:self.sync_key_cur syncKeyMax:self.sync_key_max];
            }

        }
        failure:^(NSError *error) {
            LogError(@"%@", error);
        }];
}

- (void)newSync
{
    NewSyncRequest *req = [NewSyncRequest new];
    req.tag1 = @"";
    req.selector = 262151;
    req.keyBuf = self.sync_key_cur;
    req.scene = 7;
    req.deviceType = DEVICE_TYPE;
    req.syncMsgDigest = 1;

    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 138;
    wrap.cmdId = 121;
    wrap.request = req;
    wrap.needSetBaseRequest = NO;
    wrap.responseClass = [new_sync_resp class];

    [[WeChatClient sharedClient] startRequest:wrap
        success:^(new_sync_resp *_Nullable response) {
            LogInfo(@"new sync resp: %@", response);
        }
        failure:^(NSError *error) {
            LogError(@"new sync resp error: %@", error);
        }];
}

- (void)heartBeat
{
    NSData *heart = [long_pack pack:-1 cmdId:CMDID_NOOP_REQ shortData:nil];
    [_mmtlsClient mmtlsEnCryptAndSend:heart];
}

#pragma mark - Public

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock
{
    [[self sharedClient] startRequest:cgiWrap success:successBlock failure:failureBlock];
}

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock
{

    if (cgiWrap.needSetBaseRequest)
    {
        BaseRequest *base = [BaseRequest new];
        [base setSessionKey:[[DBManager sharedManager] getSessionKey]];
        [base setUin:(int32_t)[WXUserDefault getUIN]];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:DEVICE_TYPE];
        [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];

        [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
    }

    LogInfo(@"Start Request: \n\n%@\n", cgiWrap.request);

    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [self pack:[cgiWrap cmdId] cgi:[cgiWrap cgi] serilizedData:serilizedData type:5];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    [_mmtlsClient mmtlsEnCryptAndSend:sendData];
}

- (void)manualAuth:(CgiWrap *)cgiWrap
           success:(SuccessBlock)successBlock
           failure:(FailureBlock)failureBlock
{
    ManualAuthRequest *request = (ManualAuthRequest *) [cgiWrap request];
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

    NSData *head = [header make_header:cgiWrap.cgi encryptMethod:RSA bodyData:body compressedBodyData:body needCookie:NO cookie:nil uin:_uin];

    NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
    [longlinkBody appendData:body];

    NSData *sendData = [long_pack pack:_seq++ cmdId:cgiWrap.cmdId shortData:longlinkBody];

    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];

    [_mmtlsClient mmtlsEnCryptAndSend:sendData];
}

#pragma mark - Pack

- (Task *)getTaskWithTag:(NSInteger)tag
{
    Task *result = nil;
    for (int i = 0; i < [_tasks count]; i++)
    {
        Task *task = [_tasks objectAtIndex:i];
        if (task.cgiWrap.cgi == tag)
        {
            result = task;
        }
    }
    
    return result;
}

- (void)UnPack:(NSData *)data
{
    ShortPackage *package = [short_pack unpack:data];
    NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
    NSData *protobufData = [package.body aesDecryptWithKey:sessionKey];
    Task *task = [self getTaskWithTag:package.header.cgi];
    id response = [[task.cgiWrap.responseClass alloc] initWithData:protobufData error:nil];
    if (task.sucBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((SuccessBlock) task.sucBlock)(response);
        });
        [_tasks removeObject:task];
    }
}

- (NSData *)pack:(int)cmdId cgi:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type
{
    NSData *shortLinkBuf = [short_pack pack:cgi serilizedData:serilizedData type:type uin:_uin cookie:_cookie];
    return [long_pack pack:self.seq++ cmdId:cmdId shortData:shortLinkBuf];
}

- (void)onRecivceLongLinkPlainData:(NSData *)plainData
{
    LongPackage *longLinkPackage = [long_pack unpack:plainData];
    
    switch (longLinkPackage.result)
    {
        case UnPack_Success:
        {
            LogInfo(@"Receive CmdID: %d, SEQ: %d, BodyLen: %d", longLinkPackage.header.cmdId, longLinkPackage.header.seq, longLinkPackage.header.bodyLength);
            
            if (longLinkPackage.header.bodyLength < 0x20)
            {
                switch (longLinkPackage.header.cmdId)
                {
                    case CMDID_PUSH_ACK:
                    {
                        static int push_ack_counter = 0;
                        if (push_ack_counter==0) {
                            if ([self.sync_key_cur length] == 0)
                            {
                                LogInfo(@"Start New Init.");
                                [self newInitWithSyncKeyCur:self.sync_key_cur syncKeyMax:self.sync_key_max];
                                LogInfo(@"Stop New Init.");
                            }
                        }
                        else if(push_ack_counter > 1)
                        {
                            [self newSync];
                        }
                        push_ack_counter++;
                        break;
                        
                    }
                    default:
                        break;
                }
            }
            else
            {
                ShortPackage *package = [short_pack unpack:longLinkPackage.body];
                NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
                NSData *protobufData = package.header.compressed ? [package.body aesDecrypt_then_decompress] : [package.body aesDecryptWithKey:sessionKey];
                DLog(@"Protobuf Buf", protobufData);
                Task *task = [self getTaskWithTag:package.header.cgi];
                id response = [[task.cgiWrap.responseClass alloc] initWithData:protobufData error:nil];
                if (task.sucBlock)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ((SuccessBlock) task.sucBlock)(response);
                    });
                    [_tasks removeObject:task];
                }
            }
        }
            break;
        case UnPack_Continue:
        {
        }
            break;
        default:
            break;
    }
}

@end
