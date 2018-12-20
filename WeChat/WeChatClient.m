
//  WeChatClient.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WeChatClient.h"
#import <FastSocket.h>
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

#import "ClientHello.h"
#import "ServerHello.h"
#import "WX_SHA256.h"
#import "ECDH.h"
#import "WC_HKDF.h"
#import "KeyPair.h"

#import "MMTLSShortLinkResponse.h"
#import "ShortLinkWithMMTLS.h"
#import "ShortLinkClient.h"

#import "header.h"
#import "short_pack.h"
#import "long_pack.h"

//#心跳
#define CMDID_NOOP_REQ 6
//#长链接确认
#define CMDID_IDENTIFY_REQ 205
//#登录
#define CMDID_MANUALAUTH_REQ 253

//
#define CMDID_NEWINIT_REQ 0x23

//#推送通知
#define CMDID_PUSH_ACK 24
//#通知服务器消息已接收
#define CMDID_REPORT_KV_REQ 1000000190

//#心跳包seq id
#define HEARTBEAT_SEQ 0xFFFFFFFF
//#长链接确认包seq id
#define IDENTIFY_SEQ 0xFFFFFFFE

#define HEARTBEAT_TIMEOUT 60

#define HANDSHAKE_CLIENT_HELLO 22
#define LONGLINK_HEART_BEAT 88

#define CMDID_NOOP_REQ 6
#define HEARTBEAT_SEQ 0xFFFFFFFF

#define CMDID_IDENTIFY_REQ 205
#define IDENTIFY_SEQ 0xFFFFFFFE

@interface WeChatClient ()

// longlink
@property (nonatomic, strong) FastSocket *client;
@property (nonatomic, strong) dispatch_queue_t readSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writeSerialQueue;
@property (nonatomic, assign) int seq; //封包编号。
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) NSData *cookie;
@property (nonatomic, strong) NSMutableArray *tasks;

// mmtls
@property (nonatomic, strong) NSMutableData *mmtlsReceivedBuffer;
@property (nonatomic, strong) ClientHello *clientHello;
@property (nonatomic, strong) NSMutableData *serverHelloData;
@property (nonatomic, strong) KeyPair *longlinkKeyPair;
@property (nonatomic, assign) NSInteger writeSeq;
@property (nonatomic, assign) NSInteger readSeq;

// sync_key
@property (nonatomic, strong) NSData *sync_key_cur;
@property (nonatomic, strong) NSData *sync_key_max;

@property (nonatomic, strong) NSData *shortLinkPSKData;
@property (nonatomic, strong) NSData *resumptionSecret;
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
        _writeSeq = 1;
        _readSeq = 1;

        _seq = 1;
        _uin = 0;
        
        _tasks = [NSMutableArray array];
        _mmtlsReceivedBuffer = [NSMutableData data];

        [[DBManager sharedManager] saveSessionKey:[FSOpenSSL random128BitAESKey]];      // iPad
        //[[DBManager sharedManager] saveSessionKey:[NSData GenRandomDataWithSize:184]];  // iMac

        _serverHelloData = [NSMutableData new];

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

        _readSerialQueue = dispatch_queue_create("me.ray.FastSocket.Read", DISPATCH_QUEUE_SERIAL);
        _writeSerialQueue = dispatch_queue_create("me.ray.FastSocket.Write", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (void)start
{
    FastSocket *client = [[FastSocket alloc] initWithHost:@"163.177.81.141" andPort:@"443"]; //long.weixin.qq.com 58.247.204.141
    if ([client connect])
    {
        LogInfo(@"FastSocket Connected To Server.");
        _client = client;
        [self InitLongLinkMMTLS];
        [self readData];
        
    }
    else
    {
        LogError(@"FastSocket Can Not Connect.");
    }
}

- (void)sendData:(NSData *)sendData
{
    DLog(@"SendData", sendData);
    dispatch_async(_writeSerialQueue, ^{
        long sent = [self.client sendBytes:[sendData bytes] count:[sendData length]];
        if (sent == sendData.length)
        {
            LogInfo(@"FastSocket Send all the Data, Len: %ld", sent);
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
            NSData *dataPackage = [self ReadMMTLSDataPkg];
            DLog(@"DataPkg", dataPackage);

            if ([dataPackage toInt8ofRange:0] == 0x16) //mmtls handshake
            {
                [self.serverHelloData appendData:dataPackage];
                if ([self.serverHelloData length] > 580)
                {
                    [self onReviceServerHello:[[ServerHello alloc] initWithData:self.serverHelloData]];
                }
            }
            else if ([dataPackage toInt8ofRange:0] == 0x17) //application data
            {
                [self onReceive:dataPackage];
            }
        }
    });
}

- (NSData *)ReadMMTLSDataPkg
{
    NSMutableData *header = [NSMutableData dataWithLength:5];
    long received = [_client receiveBytes:[header mutableBytes] count:5];
    if (received == 5)
    {
//        LogInfo(@"Read 5 bytes Head.");
    }

    int32_t payloadLength = [header toInt16ofRange:NSMakeRange(3, 2) SwapBigToHost:YES];
    NSData *payloadData = [self readPayload:payloadLength];
    [header appendData:payloadData];
    
    return [header copy];
}

- (NSData *)readPayload:(NSInteger)payloadLength
{
    NSMutableData *payload = [NSMutableData dataWithLength:payloadLength];
    long received = [_client receiveBytes:[payload mutableBytes] count:payloadLength];
    if (received == payloadLength)
    {
//        LogInfo(@"Read %ld bytes Payload.", received);
        return [payload copy];
    }
    else
    {
        LogError(@"Read Payload not match expect.");
        return nil;
    }
}

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
    [self mmtlsEnCryptAndSend:heart withTag:LONGLINK_HEART_BEAT];
}

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

    [self mmtlsEnCryptAndSend:sendData withTag:cgiWrap.cgi];
}

- (void)postRequest:(CgiWrap *)cgiWrap
            success:(SuccessBlock)successBlock
            failure:(FailureBlock)failureBlock
{
    
    if (cgiWrap.needSetBaseRequest)
    {
        BaseRequest *base = [BaseRequest new];
        NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
        [base setSessionKey:sessionKey];
        [base setUin:(int32_t)[WXUserDefault getUIN]];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:DEVICE_TYPE];
        [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
        
        [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
    }
    
    LogInfo(@"Start Request: %@", cgiWrap.request);
    
    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [short_pack pack:cgiWrap.cgi serilizedData:serilizedData type:5 uin:_uin cookie:_cookie];
    
    NSData *decryptedPart2 = _shortLinkPSKData;
    NSData *resumptionSecret = _resumptionSecret;
    
    NSData *httpData = [ShortLinkClient getPayloadDataWithData:sendData cgiPath:cgiWrap.cgiPath host:@"short.weixin.qq.com"];
    DLog(@"HttpData", httpData);
    
    ShortLinkWithMMTLS *slm = [[ShortLinkWithMMTLS alloc] initWithDecryptedPart2:decryptedPart2 resumptionSecret:resumptionSecret httpData:httpData];
    NSData *mmtlsData = [slm getSendData];
    
    DLog(@"Send mmtlsData", mmtlsData);
    
    NSData *rcvData = [ShortLinkClient mmPost:mmtlsData withHost:@"short.weixin.qq.com"];
    
    DLog(@"RCV mmtlsData", rcvData);
    
    MMTLSShortLinkResponse *response = [[MMTLSShortLinkResponse alloc] initWithData:rcvData];
    NSData *packData = [slm receiveData:response];
    [self UnPack:packData];
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
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

    [self mmtlsEnCryptAndSend:sendData withTag:cgiWrap.cgi];
}

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

#pragma mark - MMTLS

- (void)mmtlsEnCryptAndSend:(NSData *)sendData withTag:(NSInteger)tag
{
    NSData *writeIV = [WC_Hex IV:_longlinkKeyPair.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"00000000000000"];
    aadd = [aadd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) (_writeSeq - 1)]]];
    aadd = [[aadd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int32_t)([sendData length] + 0x10) flip:YES]]; //0x10 aad len

    NSData *mmtlsData = [WC_AesGcm128 aes128gcmEncrypt:sendData aad:aadd key:_longlinkKeyPair.writeKEY ivec:writeIV];

    NSData *sendMsgData = [[NSData dataWithHexString:@"17F103"] addDataAtTail:[NSData packInt16:(int16_t)([sendData length] + 0x10) flip:YES]];
    sendMsgData = [sendMsgData addDataAtTail:mmtlsData];

    NSString *logTag = [NSString stringWithFormat:@"MMTLS Send(%ld)", [sendMsgData length]];
    DLog(logTag, sendMsgData);
    
    [self sendData:sendMsgData];
}

- (NSData *)mmtlsDeCryptData:(NSData *)encrypedData
{
    NSData *aad = [NSData dataWithHexString:@"00000000000000"];
    aad = [aad addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) _readSeq]]];
    aad = [aad addDataAtTail:[encrypedData subdataWithRange:NSMakeRange(0, 5)]];

    NSData *readIV = [WC_Hex IV:_longlinkKeyPair.readIV XORSeq:_readSeq++];
    NSData *plainText = [WC_AesGcm128 aes128gcmDecrypt:[encrypedData subdataWithRange:NSMakeRange(5, [encrypedData length] - 5)] aad:aad key:_longlinkKeyPair.readKEY ivec:readIV];

    return plainText;
}

- (void)InitLongLinkMMTLS
{
    _clientHello = [ClientHello new];
    NSData *clientHelloData = [_clientHello CreateClientHello];
    [self sendData:clientHelloData];
}

- (void)onReviceServerHello:(ServerHello *)serverHello
{
    NSData *hashPart1 = [_clientHello getHashPart];
    NSData *hashPart2 = [serverHello getHashPart];
    NSMutableData *hashData = [NSMutableData dataWithData:hashPart1];
    [hashData appendData:hashPart2];
    NSData *HandshakeKeyExpansionHash = [WX_SHA256 sha256:hashData];

    DLog(@"handshake key expansion handshake_hash", HandshakeKeyExpansionHash);

    NSData *serverPublicKey = [serverHello getServerPublicKey];
    NSData *localPriKey = [_clientHello getLocal1stPrikey];

    NSData *EphemeralSecret = [ECDH DoEcdh2:415 ServerPubKey:serverPublicKey LocalPriKey:localPriKey];

    DLog(@"secret", EphemeralSecret);

    NSMutableData *HandshakeKeyExpansionHashInfo = [NSMutableData dataWithData:[@"handshake key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [HandshakeKeyExpansionHashInfo appendData:HandshakeKeyExpansionHash];

    NSData *HandShakeKey = [WC_HKDF HKDF_Expand:EphemeralSecret Info:[HandshakeKeyExpansionHashInfo copy]];

    DLog(@"Key expand", HandShakeKey);

    KeyPair *keyPair = [[KeyPair alloc] initWithData:HandShakeKey];

    /******************************** 开始解密PSK ****************************************/
    // Part1 decrypt
    NSData *part1 = [serverHello getPart1];

    NSMutableData *aad1 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[part1 length] flip:NO]];

    NSData *readIV1 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始。

    DLog(@"after XOR readIV 1", readIV1);

    NSData *plainText1 = [WC_AesGcm128 aes128gcmDecrypt:part1 aad:[aad1 copy] key:keyPair.readKEY ivec:readIV1];

    DLog(@"decrypted part1", plainText1);

    // Part2 decrypt
    NSData *part2 = [serverHello getPart2];

    NSMutableData *aad2 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad2 appendData:[NSData packInt32:(int32_t)[part2 length] flip:NO]];

    NSData *readIV2 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始，每次+1；

    DLog(@"after XOR readIV 2", readIV2);

    NSData *plainText2 = [WC_AesGcm128 aes128gcmDecrypt:part2 aad:[aad2 copy] key:keyPair.readKEY ivec:readIV2];

    DLog(@"decrypted part2", plainText2);

    {
        NSData *data = [plainText2 subdataWithRange:NSMakeRange(9, 100)];
        DLog(@"PSK", data);
        _shortLinkPSKData = data;

        NSData *hashDataTmp = hashData;
        hashDataTmp = [hashDataTmp addDataAtTail:plainText1];
        NSData *hashResult = [WX_SHA256 sha256:hashDataTmp];

        // 需要密钥扩展一次结果。
        NSMutableData *info222 = [NSMutableData dataWithData:[@"PSK_ACCESS" dataUsingEncoding:NSUTF8StringEncoding]];
        [info222 appendData:hashResult];

        NSData *ResumptionSecret = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:info222]; //expanded secret

        DLog(@"resumptionSecret", ResumptionSecret); //OK
        _resumptionSecret = ResumptionSecret;
    }

    // Part3 decrypt
    NSData *part3 = [serverHello getPart3];

    NSMutableData *aad3 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad3 appendData:[NSData packInt32:(int32_t)[part3 length] flip:NO]];

    NSData *readIV3 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始，每次+1；

    DLog(@"after XOR readIV 3", readIV3);

    NSData *plainText3 = [WC_AesGcm128 aes128gcmDecrypt:part3 aad:[aad3 copy] key:keyPair.readKEY ivec:readIV3];

    DLog(@"decrypted part3", plainText3);

    /******************************** 解密PSK结束 (OK) ****************************************/

    /******************************** 长连接 加密KEY & IV 的计算 **************************/
    //1.需要第二部分解密结果的hash 结果。
    NSMutableData *md = [NSMutableData dataWithData:hashData];
    [md appendData:plainText1];
    [md appendData:plainText2];
    NSData *ApplicationDataKeyExpansionHash = [WX_SHA256 sha256:md];

    DLog(@"PlainText2 Hash Result", ApplicationDataKeyExpansionHash); //OK
    // 需要密钥扩展一次结果。
    NSMutableData *ApplicationDataKeyExpansion = [NSMutableData dataWithData:[@"application data key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [ApplicationDataKeyExpansion appendData:ApplicationDataKeyExpansionHash];

    //2. secret
    NSMutableData *ExpandedSecret = [NSMutableData dataWithData:[@"expanded secret" dataUsingEncoding:NSUTF8StringEncoding]];
    [ExpandedSecret appendData:ApplicationDataKeyExpansionHash];

    NSData *ExpandSecretKey = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:ExpandedSecret]; //expanded secret

    DLog(@"ExpandSecretKey", ExpandSecretKey); //OK

    NSData *ApplicationDataKey = [WC_HKDF HKDF_Expand:ExpandSecretKey Info:[ApplicationDataKeyExpansion copy]]; //长连接 加解密 key iv 生成。 //application data key expansion

    DLog(@"ApplicationDataKey", ApplicationDataKey);

    /******************************** 长连接 加密KEY & IV 的计算（OK） **************************/

    /******************************** 心跳请求组包 **************************/

    // 1. 心跳请求第一部分数据。
    NSData *clientFinished = [@"client finished" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ClientFinishedKey = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:clientFinished]; //OK //client finished

    NSData *hmacResult = [WX_HmacSha256 HmacSha256WithKey:ClientFinishedKey data:ApplicationDataKeyExpansionHash]; //OK

    NSMutableData *heartbeatPart1 = [NSMutableData dataWithHexString:@"00000023140020"];
    [heartbeatPart1 appendData:hmacResult];

    NSData *aadddd = [NSData dataWithHexString:@"000000000000000116F1030037"];

    NSData *writeIV1 = [WC_Hex IV:keyPair.writeIV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    NSData *heartbeatPart1CipherText = [WC_AesGcm128 aes128gcmEncrypt:heartbeatPart1 aad:aadddd key:keyPair.writeKEY ivec:writeIV1];
    NSMutableData *heartbeatData1 = [NSMutableData dataWithHexString:@"16F1030037"];
    [heartbeatData1 appendData:heartbeatPart1CipherText];
    DLog(@"HeartBeat 1", heartbeatData1);

    // 2. 心跳包数据。
    KeyPair *keyPair2 = [[KeyPair alloc] initWithData:ApplicationDataKey];
    NSData *writeIV = [WC_Hex IV:keyPair2.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"000000000000000217F1030020"];

    _longlinkKeyPair = keyPair2;
    NSData *heart = [long_pack pack:-1 cmdId:CMDID_NOOP_REQ shortData:nil];
    NSData *heartbeatCipherText = [WC_AesGcm128 aes128gcmEncrypt:heart aad:aadd key:keyPair2.writeKEY ivec:writeIV];

    NSMutableData *heartbeatData = [NSMutableData dataWithHexString:@"17f1030020"];
    [heartbeatData appendData:heartbeatCipherText];

    //    DLog(@"HeartBeat 2", heartbeatData); //OK

    // 3. 心跳包加一块.
    NSMutableData *hb = [NSMutableData dataWithCapacity:[heartbeatData1 length] + [heartbeatData length]];
    [hb appendData:heartbeatData1];
    [hb appendData:heartbeatData];
    DLog(@"HB", hb);

    [self sendData:hb];
}

#pragma mark - UnPackLong

- (void)onReceive:(NSData *)data
{
    NSString *logTag = [NSString stringWithFormat:@"MMTLS Receive(%ld)", [data length]];
    DLog(logTag, data);
    
    NSData *plainText = [self mmtlsDeCryptData:data];

    logTag = [NSString stringWithFormat:@"MMTLS Decrypted(%ld)", [data length]];
    DLog(logTag, plainText);
    
    LongPackage *longLinkPackage = [long_pack unpack:plainText];

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
//                        static int push_ack_counter = 0;
//                        if (push_ack_counter==0) {
//                            if ([self.sync_key_cur length] == 0)
//                            {
//                                LogInfo(@"Start New Init.");
//                                [self newInitWithSyncKeyCur:self.sync_key_cur syncKeyMax:self.sync_key_max];
//                                LogInfo(@"Stop New Init.");
//                            }
//                        }
//                        else if(push_ack_counter > 1)
//                        {
//                            [self newSync];
//                        }
//                        push_ack_counter++;
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

    //清空tls数据
    [_mmtlsReceivedBuffer setData:[NSData data]];
}

#pragma mark - Pack

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

@end
