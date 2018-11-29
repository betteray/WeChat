
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

#import "ClientHello.h"
#import "ServerHello.h"
#import "WX_SHA256.h"
#import "ECDH.h"
#import "WX_HKDF.h"
#import "KeyPair.h"

//#心跳
#define CMDID_NOOP_REQ 6
//#长链接确认
#define CMDID_IDENTIFY_REQ 205
//#登录
#define CMDID_MANUALAUTH_REQ 253
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

typedef NS_ENUM(NSInteger, UnPackResult) {
    UnPack_Fail,
    UnPack_Continue,
    UnPack_Success
};

@interface WeChatClient()<GCDAsyncSocketDelegate>

// longlink
@property (nonatomic, strong) GCDAsyncSocket    *socket;
@property (nonatomic, strong) NSMutableData     *recvedData;
@property (nonatomic, assign) int               seq;    //封包编号。
@property (nonatomic, strong) NSTimer           *heartbeatTimer;
@property (nonatomic, strong) NSData            *cookie;
@property (nonatomic, strong) NSMutableArray    *tasks;

// mmtls
@property (nonatomic, strong) ClientHello   *clientHello;
@property (nonatomic, strong) KeyPair       *longlinkKeyPair;
@property (nonatomic, assign) NSInteger     writeSeq;
@property (nonatomic, assign) NSInteger     readSeq;

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
        _writeSeq = 1;
        _readSeq = 1;
        
        _seq = 1;
        _uin = 0;
        _tasks = [NSMutableArray array];
        _recvedData = [NSMutableData data];
        _sessionKey = [FSOpenSSL random128BitAESKey]; // iPad
//        _sessionKey = [NSData GenRandomDataWithSize:184]; //iMac

        NSString *priKey = nil;
        NSString *pubKey = nil;
        if ([MarsOpenSSL genRSAKeyPairPubKey:&pubKey priKey:&priKey]) {
            _priKey = [priKey dataUsingEncoding:NSUTF8StringEncoding];
            _pubKey = [pubKey dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            NSLog(@" ** Gen RSA KeyPair Fail. ** ");
        }
        
        _heartbeatTimer = [NSTimer timerWithTimeInterval:3*60 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
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
    [_socket connectToHost:@"163.177.81.141" onPort:443 error:&error]; //long.weixin.qq.com 58.247.204.141
    if (error) {
        NSLog(@"Socks Start Error: %@", [error localizedDescription]);
    }
    [self DoSendClientHello];
}

- (void)readDataManually {
    [_socket readDataWithTimeout:3 tag:0];
}

- (void)DoSendClientHello {
    _clientHello = [ClientHello new];
    NSData *clientHelloData = [_clientHello CreateClientHello];
    [_socket writeData:clientHelloData withTimeout:HEARTBEAT_TIMEOUT tag:HANDSHAKE_CLIENT_HELLO];
}

- (void)newInitWithSyncKeyCur:(NSData *)syncKeyCur syncKeyMax:(NSData *)syncKeyMax {
    NewInitRequest *request = [NewInitRequest new];
    request.wxid = [WXUserDefault getWXID];
    request.syncKeyCur = syncKeyCur;
    request.syncKeyMax = syncKeyMax;
    request.language = LANGUAGE;
    
    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 139;
    wrap.cmdId = 27;
    wrap.request = request;
    wrap.responseClass = [NewInitResponse class];
    
    [[WeChatClient sharedClient] startRequest:wrap success:^(NewInitResponse * _Nullable response) {
        NSLog(@"%@", response);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
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

- (void)heartBeat {
    NSData *heart = [self longlink_packWithSeq:_seq cmdId:CMDID_NOOP_REQ buffer:nil];
    
    NSData *writeIV = [WX_Hex IV:_longlinkKeyPair.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"00000000000000"];
    aadd = [aadd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", _writeSeq - 1]]];
    aadd = [[aadd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int16_t) ([heart length] + 0x10) flip:YES]];
    
    NSData *heartbeatCipherText = nil;
    [WX_AesGcm128 aes128gcmEncrypt:heart ciphertext:&heartbeatCipherText aad:aadd key:_longlinkKeyPair.writeKEY ivec:writeIV];
    
    NSData *heartbeatData = [[NSData dataWithHexString:@"17f103"] addDataAtTail:[NSData packInt16:(int16_t) ([heart length] + 0x10) flip:YES]];
    heartbeatData = [heartbeatData addDataAtTail:heartbeatCipherText];
    
    DLog(@"HB", heartbeatData);
    
    [_socket writeData:heartbeatData withTimeout:HEARTBEAT_TIMEOUT tag:LONGLINK_HEART_BEAT];
}

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    [[self sharedClient] startRequest:cgiWrap success:successBlock failure:failureBlock];
}

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock {
    
    if (!cgiWrap.needSetBaseRequest) {
        BaseRequest *base = [BaseRequest new];
        [base setSessionKey:_sessionKey];
        [base setUin:(int32_t) [WXUserDefault getUIN]];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:DEVICE_TYPE];
        [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
        
        [[cgiWrap request] performSelector:@selector(baseRequest:) withObject:base];
    }
    
    NSData *serilizedData = [[cgiWrap request] data];
    NSData *sendData = [self pack:[cgiWrap cmdId] cgi:[cgiWrap cgi] serilizedData:serilizedData type:5];
    
    DLog(@"SendData", sendData);
    
    NSData *writeIV = [WX_Hex IV:_longlinkKeyPair.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"00000000000000"];
    aadd = [aadd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", _writeSeq - 1]]];
    aadd = [[aadd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int32_t) ([sendData length] + 0x10) flip:YES]]; //0x10 aad len
    NSData *manulauth = nil;
    [WX_AesGcm128 aes128gcmEncrypt:sendData ciphertext:&manulauth aad:aadd key:_longlinkKeyPair.writeKEY ivec:writeIV];
    
    NSData *sendMsgData = [[NSData dataWithHexString:@"17F103"] addDataAtTail:[NSData packInt16:(int16_t) ([sendData length] + 0x10) flip:YES]];
    sendMsgData = [sendMsgData addDataAtTail:manulauth];
    
    DLog(@"SendMsgData", sendMsgData);
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
    
    [_socket writeData:sendMsgData withTimeout:3 tag:cgiWrap.cgi];
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
    
    NSData *sendData = [self longlink_packWithSeq:6 cmdId:cgiWrap.cmdId buffer:longlinkBody];
    
    DLog(@"ManualAuthData", sendData)
    
    NSData *writeIV = [WX_Hex IV:_longlinkKeyPair.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"00000000000000"];
    aadd = [aadd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", _writeSeq - 1]]];
    aadd = [[aadd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int32_t) ([sendData length] + 0x10) flip:YES]]; //0x10 aad len
    NSData *manulauth = nil;
    [WX_AesGcm128 aes128gcmEncrypt:sendData ciphertext:&manulauth aad:aadd key:_longlinkKeyPair.writeKEY ivec:writeIV];
    
    NSData *manualAuthSendData = [[NSData dataWithHexString:@"17F103"] addDataAtTail:[NSData packInt16:(int16_t) ([sendData length] + 0x10) flip:YES]];
    manualAuthSendData = [manualAuthSendData addDataAtTail:manulauth];
    
    DLog(@"manual auth", manualAuthSendData);
    
    Task *task = [Task new];
    task.sucBlock = successBlock;
    task.failBlock = failureBlock;
    task.cgiWrap = cgiWrap;
    [_tasks addObject:task];
    
    [_socket writeData:manualAuthSendData withTimeout:3 tag:[cgiWrap cgi]];
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

#pragma mark - MMTLS

- (void)onReviceServerHello:(ServerHello *)serverHello {
    
    NSData *hashPart1 = [_clientHello getHashPart];
    NSData *hashPart2 = [serverHello getHashPart];
    NSMutableData *hashData = [NSMutableData dataWithData:hashPart1];
    [hashData  appendData:hashPart2];
    NSData *hashResult = [WX_SHA256 sha256:hashData];
    
    DLog(@"Hash Result", hashResult);
    
    NSData *serverPublicKey = [serverHello getServerPublicKey];
    NSData *localPriKey = [_clientHello getLocal1stPrikey];
    
    unsigned char buf[32] = {0};
    int sharedKeyLen = 0;
    [ECDH DoEcdh2:415
   szServerPubKey:(unsigned char *) [serverPublicKey bytes] nLenServerPub:(int) [serverPublicKey length]
    szLocalPriKey:(unsigned char *) [localPriKey bytes] nLenLocalPri:(int) [localPriKey length]
       szShareKey:buf pLenShareKey:&sharedKeyLen];
    NSData *secret = [NSData dataWithBytes:buf length:sharedKeyLen];
    
    DLog(@"secret", secret);
    
    NSMutableData *info = [NSMutableData dataWithData: [@"handshake key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [info appendData:hashResult];
    
    NSData *outOkm = nil;
    [WX_HKDF HKDF_Expand_Prk:secret Info:[info copy] outOkm:&outOkm];
    
    DLog(@"Key expand", outOkm);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithData:outOkm];
    
    
    /******************************** 开始解密PSK ****************************************/
    // Part1 decrypt
    NSData *part1 = [serverHello getPart1];
    
    NSMutableData *aad1 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[part1 length] flip:NO]];
    
    NSData *readIV1 = [WX_Hex  IV:keyPair.readIV XORSeq:_readSeq++];//序号从1开始。
    
    DLog(@"after XOR readIV 1", readIV1);
    
    NSData *plainText1 = nil;
    [WX_AesGcm128 aes128gcmDecrypt:part1 plaintext:&plainText1 aad:[aad1 copy] key:keyPair.readKEY ivec:readIV1];
    
    DLog(@"decrypted part1", plainText1);
    
    
    // Part2 decrypt
    NSData *part2 = [serverHello getPart2];
    
    NSMutableData *aad2 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad2 appendData:[NSData packInt32:(int32_t)[part2 length] flip:NO]];
    
    NSData *readIV2 = [WX_Hex  IV:keyPair.readIV XORSeq:_readSeq++];//序号从1开始，每次+1；
    
    DLog(@"after XOR readIV 2", readIV2);
    
    NSData *plainText2 = nil;
    [WX_AesGcm128 aes128gcmDecrypt:part2 plaintext:&plainText2 aad:[aad2 copy] key:keyPair.readKEY ivec:readIV2];
    
    DLog(@"decrypted part2", plainText2);
    
    
    // Part3 decrypt
    NSData *part3 = [serverHello getPart3];
    
    NSMutableData *aad3 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad3 appendData:[NSData packInt32:(int32_t)[part3 length] flip:NO]];
    
    NSData *readIV3 = [WX_Hex  IV:keyPair.readIV XORSeq:_readSeq++];//序号从1开始，每次+1；
    
    DLog(@"after XOR readIV 3", readIV3);
    
    NSData *plainText3 = nil;
    [WX_AesGcm128 aes128gcmDecrypt:part3 plaintext:&plainText3 aad:[aad3 copy] key:keyPair.readKEY ivec:readIV3];
    
    DLog(@"decrypted part3", plainText3);
    
    
    /******************************** 解密PSK结束 (OK) ****************************************/
    
    /******************************** 长连接 加密KEY & IV 的计算 **************************/
    //1.需要第二部分解密结果的hash 结果。
    NSMutableData *md = [NSMutableData dataWithData:hashData];
    [md appendData:plainText1];
    [md appendData:plainText2];
    NSData *plainText2HashData = [WX_SHA256 sha256:md];
    
    DLog(@"PlainText2 Hash Result", plainText2HashData); //OK
    // 需要密钥扩展一次结果。
    NSMutableData *info2 = [NSMutableData dataWithData: [@"application data key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [info2 appendData:plainText2HashData];
    
    //2. secret
    NSMutableData *info3 = [NSMutableData dataWithData: [@"expanded secret" dataUsingEncoding:NSUTF8StringEncoding]];
    [info3 appendData:plainText2HashData];
    
    NSData *outOkm2 = nil;
    [WX_HKDF HKDF_Expand_Prk2:secret Info:info3 outOkm:&outOkm2]; //expanded secret
    
    DLog(@"outOkm2", outOkm2);//OK
    
    NSData *outOkm3 = nil;
    [WX_HKDF HKDF_Expand_Prk:outOkm2 Info:[info2 copy] outOkm:&outOkm3];//长连接 加解密 key iv 生成。 //application data key expansion
    
    DLog(@"outOkm3", outOkm3);
    
    /******************************** 长连接 加密KEY & IV 的计算（OK） **************************/
    
    /******************************** 心跳请求组包 **************************/
    
    // 1. 心跳请求第一部分数据。
    NSData *clientFinished = [@"client finished" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *outOkm4 = nil;
    [WX_HKDF HKDF_Expand_Prk2:secret Info:clientFinished outOkm:&outOkm4]; //OK //client finished
    
    NSData *hmacResult = nil;
    [WX_HmacSha256 HmacSha256WithKey:outOkm4 data:plainText2HashData result:&hmacResult]; //OK
    
    NSMutableData *heartbeatPart1 = [NSMutableData dataWithHexString:@"00000023140020"];
    [heartbeatPart1 appendData:hmacResult];
    
    NSData *aadddd = [NSData dataWithHexString:@"000000000000000116F1030037"];
    NSData *heartbeatPart1CipherText = nil;
    
    NSData *writeIV1 = [WX_Hex  IV:keyPair.writeIV XORSeq:_writeSeq++];//序号从1开始，每次+1；
    [WX_AesGcm128 aes128gcmEncrypt:heartbeatPart1 ciphertext:&heartbeatPart1CipherText aad:aadddd key:keyPair.writeKEY ivec:writeIV1];
    NSMutableData *heartbeatData1 = [NSMutableData dataWithHexString:@"16F1030037"];
    [heartbeatData1 appendData:heartbeatPart1CipherText];
    DLog(@"HeartBeat 1", heartbeatData1);
    
    // 2. 心跳包数据。
    KeyPair *keyPair2 = [[KeyPair alloc] initWithData:outOkm3];
    NSData *writeIV = [WX_Hex IV:keyPair2.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"000000000000000217F1030020"];
    
    _longlinkKeyPair = keyPair2;
    NSData *heartbeatCipherText = nil;
    NSData *heart = [self longlink_packWithSeq:_seq cmdId:CMDID_NOOP_REQ buffer:nil];
    [WX_AesGcm128 aes128gcmEncrypt:heart ciphertext:&heartbeatCipherText aad:aadd key:keyPair2.writeKEY ivec:writeIV];
    
    NSMutableData *heartbeatData = [NSMutableData dataWithHexString:@"17f1030020"];
    [heartbeatData appendData:heartbeatCipherText];
    
    DLog(@"HeartBeat 2", heartbeatData); //OK
    
    // 3. 心跳包加一块.
    NSMutableData *hb = [NSMutableData dataWithCapacity:[heartbeatData1 length] + [heartbeatData length]];
    [hb appendData:heartbeatData1];
    [hb appendData:heartbeatData];
    DLog(@"HB", hb);
    
    [_socket writeData:hb withTimeout:3 tag:LONGLINK_HEART_BEAT];
}

- (void)onReceive:(NSData *)data withTag:(NSInteger) tag{
    
    NSData *aad = [NSData dataWithHexString:@"00000000000000"];
    aad = [aad addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", _readSeq]]];
    aad = [aad addDataAtTail:[data subdataWithRange:NSMakeRange(0, 5)]];
    
    NSData *plainText = nil;
    NSData *readIV = [WX_Hex IV:_longlinkKeyPair.readIV XORSeq:_readSeq++];
    [WX_AesGcm128 aes128gcmDecrypt:[data subdataWithRange:NSMakeRange(5, [data length] - 5)] plaintext:&plainText aad:aad key:_longlinkKeyPair.readKEY ivec:readIV];
    
    DLog(@"OnReceive", plainText);
    
    LongLinkPackage *longLinkPackage = [LongLinkPackage new];
    UnPackResult result = [self unPackLongLink:plainText toLongLingPackage:longLinkPackage];

    switch (result) {
        case UnPack_Success: {
            NSLog(@">>> LongLinkPackage Head CmdId: %d", longLinkPackage.header.cmdId);

            if (longLinkPackage.header.bodyLength < 0x20) {
                switch (longLinkPackage.header.cmdId) {
                    case CMDID_PUSH_ACK:
                        NSLog(@"Start New Init.");
                        [self newInitWithSyncKeyCur:nil syncKeyMax:nil];
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
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *logTag = [NSString stringWithFormat:@"DidReadDataWithTag: %ld", tag];
    DLog(logTag, data);
    
    if (tag==HANDSHAKE_CLIENT_HELLO) {
        ServerHello *serverHello = [[ServerHello alloc] initWithData:data];
        [self onReviceServerHello:serverHello];
    } else {
        [self onReceive:data withTag:tag];
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
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
            NSData *head = [self make_header:cgi encryptMethod:AES bodyData:serilizedData compressedBodyData:serilizedData needCookie:YES];
            NSData *body = [serilizedData AES];
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
    
//    if (_checkEcdhKey.length > 0) {
//        [header appendData:[self ecdhCheck:bodyData]];
//    }
    
    if (need_login_rsa_verison(cgi)) {
        [header appendData:[Varint128 dataWithUInt32:LOGIN_RSA_VER_172]];
        [header appendData:[NSData dataWithHexString:@"0D00"]];
        [header appendData:[NSData packInt16:9 flip:NO]];
    } else {
//        [header appendData:[NSData dataWithHexString:@"000D"]];
//        [header appendData:[NSData packInt16:(9 * (1 & 7)) flip:NO]];   //need fix
        [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
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
