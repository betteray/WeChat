
//  WeChatClient.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WeChatClient.h"
#import <FastSocket.h>
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

#import "ClientHello.h"
#import "ServerHello.h"
#import "WX_SHA256.h"
#import "ECDH.h"
#import "WC_HKDF.h"
#import "KeyPair.h"

#import "MMTLSShortLinkResponse.h"
#import "ShortLinkWithMMTLS.h"
#import "ShortLinkClient.h"

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

typedef NS_ENUM(int, EncryptMethod) {
    NONE = 0x1,
    AES = 0x5,
    RSA = 0x7,
};

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
        _sessionKey = [FSOpenSSL random128BitAESKey]; // iPad
                                                      //        _sessionKey = [NSData GenRandomDataWithSize:184]; //iMac

        _serverHelloData = [NSMutableData new];

        _sync_key_cur = [NSData data];
        _sync_key_max = [NSData data];

        NSString *priKey = nil;
        NSString *pubKey = nil;
        if ([MarsOpenSSL genRSAKeyPairPubKey:&pubKey priKey:&priKey])
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

- (void)restartUsingIpAddress:(NSString *)IpAddress
{
    //    [_socket disconnect];

    //    NSError *error;
    //    [_socket connectToHost:IpAddress onPort:80 error:&error];
    //    if (error)
    //    {
    //        NSLog(@"Socks ReStart Error: %@", [error localizedDescription]);
    //        return;
    //    }
    //    [self heartBeat];
}

- (void)heartBeat
{
    NSData *heart = [self longlink_packWithSeq:-1 cmdId:CMDID_NOOP_REQ buffer:nil];
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
        [base setSessionKey:_sessionKey];
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
        [base setSessionKey:_sessionKey];
        [base setUin:(int32_t)[WXUserDefault getUIN]];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:DEVICE_TYPE];
        [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];

        [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
    }

    LogInfo(@"Start Request: %@", cgiWrap.request);

    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [self shortlinkPackWithCgi:cgiWrap.cgi serilizedData:serilizedData type:5];

    NSData *decryptedPart2 = _shortLinkPSKData;
    NSData *resumptionSecret = _resumptionSecret;
    NSData *httpData = [self getHttpDataWithShortLinkPackData:sendData cgiPath:cgiWrap.cgiPath host:@"short.weixin.qq.com"];
    DLog(@"HttpData", httpData);
//        httpData = [NSData dataWithHexString:@"0000023D002E2F6367692D62696E2F6D6963726F6D73672D62696E2F656E6372797074636865636B74696E6B6572757064617465001373686F72742E77656978696E2E71712E636F6D000001F4BF62701607032100000000B401DC03DC03B201010009000000000016000000DE00000100816F467E57C38275CB7239664D3F436DA6090E4AB8C71D5E01C73BB5A2EAD9F2B8CD124B75EFBCC590658A6C2D2218DBCFD02AD485C6BE91C163E6FEE8BF5C40E134047DD9F33D7A029018E12EB742CDADC756599749FAF22592B23BFFE6F6C8A1BECAB5060273839459F5D417829AD1D340DFF70E198AA63BADEC0BA000F71F4F9B64044236C6CFAA66549A1CDD1ACCCA3A4FA9F0674DF8248F37C7DD2923D8C069786EA2EE30DD110FC2A4047BBB06DECB9EE189A720931987F69BDB15C53CD18DA42096BA9CAC468D8CB222A23FBECCF8168C8669227C9EF963D49DF3352C90136CF3548FBED0A0B06555ACDB81F24A8FB19F6F8B195BACB38B1906BF648E3BB86A675A64639F0F6FE788373041D2DCA3CC7D7A79A01CAA8C161695FB22D3DE70B8124813C69BB08571A17B0AAA7716D2819AD2FD8A981DD5083DC52E7F3D67F9B7814FCBE5C3C312E226A8E3F97FA114D0AF86ABC2D643722D2F065359ABE7066192A3F5B42938AF04A218F1F248256BB7E95952BA81632B38D252EF8344BFEFFF9D4C5A626824037B8CAD3488ACE0907C96233DDED25946A4C652B1B652E8FFC2FDCD700159FA35747C9828292907D64A5266A9F457989633BC1A5A57CE4FA4965438461EF40104D2D20CD71305"];
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

- (void)UnPack:(NSData *)data
{
    Package *package = [self UnPackLongLinkBody:data];
    NSData *protobufData = [package.body aesDecryptWithKey:_sessionKey];
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

- (NSData *)getHttpDataWithShortLinkPackData:(NSData *)shortlinkData
                                     cgiPath:(NSString *)cgiPath
                                        host:(NSString *)host
{
    NSData *len1 = [NSData packInt16:[cgiPath length] flip:YES];
    NSData *len2 = [NSData packInt16:[host length] flip:YES];
    NSData *len3 = [NSData packInt32:(int32_t)[shortlinkData length] flip:YES];
    NSData *result = [len1 addDataAtTail:[cgiPath dataUsingEncoding:NSUTF8StringEncoding]];
    result = [result addDataAtTail:len2];
    result = [result addDataAtTail:[host dataUsingEncoding:NSUTF8StringEncoding]];
    result = [result addDataAtTail:len3];
    result = [result addDataAtTail:shortlinkData];

    NSData *len4 = [NSData packInt32:(int32_t)[result length] flip:YES];
    result = [len4 addDataAtTail:result];

    return result;
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

    NSData *head = [self make_header:cgiWrap.cgi encryptMethod:RSA bodyData:body compressedBodyData:body needCookie:NO];

    NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
    [longlinkBody appendData:body];

    NSData *sendData = [self longlink_packWithSeq:_seq cmdId:cgiWrap.cmdId buffer:longlinkBody];

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
//    NSString *logTag = [NSString stringWithFormat:@"Send(%ld)", [sendData length]];
//    DLog(logTag, sendData);

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
    
    NSString *logTag = [NSString stringWithFormat:@"MMTLS Send(%ld)", [clientHelloData length]];
    DLog(logTag, clientHelloData);
    
    [self sendData:clientHelloData];
    
//    NSData *longLinkMMTLSData = [self ReadMMTLSDataPkg];
//    longLinkMMTLSData = [longLinkMMTLSData addDataAtTail:[self ReadMMTLSDataPkg]];
//    longLinkMMTLSData = [longLinkMMTLSData addDataAtTail:[self ReadMMTLSDataPkg]];
//    longLinkMMTLSData = [longLinkMMTLSData addDataAtTail:[self ReadMMTLSDataPkg]];
//
//    [self onReviceServerHello:[[ServerHello alloc] initWithData:longLinkMMTLSData]];
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
    NSData *heart = [self longlink_packWithSeq:-1 cmdId:CMDID_NOOP_REQ buffer:nil];
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
    
    LongLinkPackage *longLinkPackage = [self unPackLongLink:plainText];

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
                Package *package = [self UnPackLongLinkBody:longLinkPackage.body];
                NSData *protobufData = package.header.compressed ? [package.body aesDecrypt_then_decompress] : [package.body aesDecryptWithKey:_sessionKey];
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

- (LongLinkPackage *)unPackLongLink:(NSData *)recvdRawData
{
    LongLinkPackage *lpkg = [LongLinkPackage new];
    
    if ([recvdRawData length] < 16)
    { // 包头不完整。
        LogError(@"Should Contine Read Data: 包头不完整");
        lpkg.result = UnPack_Continue;
        return lpkg;
    }

    LongLinkHeader *header = [LongLinkHeader new];

    header.bodyLength = [recvdRawData toInt32ofRange:NSMakeRange(0, 4) SwapBigToHost:YES];
    header.headLength = [recvdRawData toInt16ofRange:NSMakeRange(4, 2) SwapBigToHost:NO] >> 8;
    header.clientVersion = [recvdRawData toInt16ofRange:NSMakeRange(6, 2) SwapBigToHost:NO] >> 8;
    header.cmdId = [recvdRawData toInt32ofRange:NSMakeRange(8, 4) SwapBigToHost:YES];
    header.seq = [recvdRawData toInt32ofRange:NSMakeRange(12, 4) SwapBigToHost:YES];
    if (header.bodyLength > [recvdRawData length])
    {
        //包未收完。
        LogError(@"Should Contine Read Data: 包未收完。");
        lpkg.result = UnPack_Continue;
        return lpkg;
    }

    lpkg.header = header;
    lpkg.body = [recvdRawData subdataWithRange:NSMakeRange(16, [recvdRawData length] - 16)];
    lpkg.result = UnPack_Success;
    
    return lpkg;
}

- (NSData *)pack:(int)cmdId cgi:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type
{
    NSData *shortLinkBuf = [self shortlinkPackWithCgi:cgi serilizedData:serilizedData type:type];
    return [self longlink_packWithSeq:self.seq cmdId:cmdId buffer:shortLinkBuf];
}

- (NSData *)shortlinkPackWithCgi:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type
{
    switch (type)
    {
        case 1:
        {
            NSData *head = [self make_header:cgi encryptMethod:NONE bodyData:serilizedData compressedBodyData:serilizedData needCookie:NO];
            NSData *body = [MarsOpenSSL RSA_PUB_EncryptData:serilizedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];

            return [longlinkBody copy];
        }
        break;
        case 5:
        {
            NSData *head = [self make_header:cgi encryptMethod:AES bodyData:serilizedData compressedBodyData:serilizedData needCookie:YES];
            NSData *body = [serilizedData AES];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];

            return [longlinkBody copy];
        }
        break;
        default:
            break;
    }

    return nil;
}

#pragma mark - longlink pack

- (NSData *)longlink_packWithSeq:(int)seq cmdId:(int)cmdId buffer:(NSData *)buffer
{
    NSMutableData *longlink_header = [NSMutableData data];

    [longlink_header appendData:[NSData packInt32:(int) ([buffer length] + 16) flip:YES]];
    [longlink_header appendData:[NSData dataWithHexString:@"0010"]];
    [longlink_header appendData:[NSData dataWithHexString:@"0001"]];
    [longlink_header appendData:[NSData packInt32:cmdId flip:YES]];

    if (cmdId == CMDID_NOOP_REQ)
    {
        [longlink_header appendData:[NSData packInt32:HEARTBEAT_SEQ flip:YES]];
    }
    else if (CMDID_IDENTIFY_REQ == cmdId)
    {
        [longlink_header appendData:[NSData packInt32:IDENTIFY_SEQ flip:YES]];
    }
    else
    {
        [longlink_header appendData:[NSData packInt32:_seq++ flip:YES]];
    }

    [longlink_header appendData:buffer];
    return [longlink_header copy];
}

#pragma mark - make header

- (int)decode:(int *)apuValue bytes:(NSData *)apcBuffer off:(int)off
{
    int num3;
    int num = 0;
    int num2 = 0;
    int num4 = 0;
    int num5 = *(int *) [[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    while ((num5 & 0xff) >= 0x80)
    {
        num3 = num5 & 0x7f;
        num4 += num3 << num2;
        num2 += 7;
        num5 = *(int *) [[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    }
    num3 = num5;
    num4 += num3 << num2;
    *apuValue = num4;
    return num;
}

- (Package *)UnPackLongLinkBody:(NSData *)body
{
    Package *package = [Package new];
    Header *header = [Header new];
    package.header = header;
    if ([body length] < 0x20)
    {
        LogError(@"UnPack BF Fail, Body too short.");
        return nil;
    }

    NSInteger index = 0;
    int mark = (int) [body toInt8ofRange:index];
    if (mark == 0xbf)
    {
        index++;
    }
    int32_t headLength = (int) [body toInt8ofRange:index] >> 2;
    header.compressed = (1 == ((int) [body toInt8ofRange:index] & 0x3));
    index++;

    header.decrytType = (int) [body toInt8ofRange:index] >> 4;
    int cookieLen = (int) [body toInt8ofRange:index] & 0xf;
    index++;
    index += 4; //服务器版本，忽略。

    _uin = (int) [body toInt8ofRange:index];
    index += 4;

    if (cookieLen > 0 && cookieLen <= 0xf)
    {
        NSData *cookie = [body subdataWithRange:NSMakeRange(index, cookieLen)];
        LogInfo(@"Cookie: %@", cookie);
        index += cookieLen;
        _cookie = cookie;
    }
    else if (cookieLen > 0xf)
    {
        LogError(@"UnPack BF Fail, cookieLen too long.");
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

    if (headLength < [body length])
    {
        package.body = [body subdataWithRange:NSMakeRange(headLength, [body length] - headLength)];
    }

    return package;
}

- (NSData *)make_header:(int)cgi encryptMethod:(EncryptMethod)encryptMethod bodyData:(NSData *)bodyData compressedBodyData:(NSData *)compressedBodyData needCookie:(BOOL)needCookie
{

    int bodyDataLen = (int) [bodyData length];
    int compressedBodyDataLen = (int) [compressedBodyData length];

    NSMutableData *header = [NSMutableData data];

    [header appendData:[NSData dataWithHexString:@"BF"]]; //
    [header appendData:[NSData dataWithHexString:@"00"]]; //包头长度，最后计算。
    int len = (encryptMethod << 4) + (needCookie ? 0xf : 0x0);
    [header appendData:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", len]]];
    [header appendData:[NSData packInt32:CLIENT_VERSION flip:YES]];
    [header appendData:[NSData packInt32:_uin flip:YES]];

    if (needCookie)
    {
        if ([_cookie length] < 0xf)
        {
            [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
        }
        else
        {
            [header appendData:_cookie];
        }
    }

    [header appendData:[Varint128 dataWithUInt32:cgi]];
    [header appendData:[Varint128 dataWithUInt32:bodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:compressedBodyDataLen]];

    //    if (_checkEcdhKey.length > 0) {
    //        [header appendData:[self ecdhCheck:bodyData]];
    //    }

    if (need_login_rsa_verison(cgi))
    {
        [header appendData:[Varint128 dataWithUInt32:LOGIN_RSA_VER_172]];
        [header appendData:[NSData dataWithHexString:@"0D00"]];
        [header appendData:[NSData packInt16:9 flip:NO]];
    }
    else
    {
        //        [header appendData:[NSData dataWithHexString:@"000D"]];
        //        [header appendData:[NSData packInt16:(9 * (1 & 7)) flip:NO]];   //need fix
        [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
    }
    
    [header replaceBytesInRange:NSMakeRange(1, 1) withBytes:[[Varint128 dataWithUInt32:(int)(([header length] << 2) + 0x2)] bytes]];
    return [header copy];
}

- (NSData *)ecdhCheck:(NSData *)buff
{
    NSData *data = [buff dataByDeflating];
    return [FSOpenSSL aesEncryptData:data key:_checkEcdhKey];
}

bool need_login_rsa_verison(int cgi)
{
    return cgi == 502 || cgi == 503 || cgi == 701;
}

@end
