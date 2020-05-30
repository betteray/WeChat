//
//  LongLinkMMTLS.m
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LongLinkClientWithMMTLS.h"
#import <FastSocket.h>

#import "ClientHello.h"
#import "ServerHello.h"
#import "Cryption/WC_SHA256.h"
#import "WCECDH.h"
#import "Cryption/WC_HKDF.h"
#import "KeyPair.h"

#import "long_pack.h"
#import "DefaultLongIp.h"

#define CMDID_NOOP_REQ 6

@interface LongLinkClientWithMMTLS ()

// longlink
@property (nonatomic, strong) FastSocket *client;

@property (nonatomic, strong) dispatch_queue_t readSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writeSerialQueue;

// mmtls
@property (nonatomic, strong) NSMutableData *mmtlsReceivedBuffer;
@property (nonatomic, strong) ClientHello *clientHello;
@property (nonatomic, strong) NSMutableData *serverHelloData;
@property (nonatomic, strong) KeyPair *longlinkKeyPair;
@property (nonatomic, assign) NSInteger writeSeq;
@property (nonatomic, assign) NSInteger readSeq;

@property (nonatomic, copy) NSString *pskFilePath;

@end

@implementation LongLinkClientWithMMTLS

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _writeSeq = 1;
        _readSeq = 1;

        _serverHelloData = [NSMutableData data];

        _readSerialQueue = dispatch_queue_create("me.ray.FastSocket.Read", DISPATCH_QUEUE_SERIAL);
        _writeSerialQueue = dispatch_queue_create("me.ray.FastSocket.Write", DISPATCH_QUEUE_SERIAL);
        
        _pskFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"psk.key"];
    }
    return self;
}

- (void)start
{
    DefaultLongIp *randomIP = [DefaultLongIp getARandomIp];
    NSString *ip = @"long.weixin.qq.com";
    NSString *port = @"443";
    if (randomIP != nil) {
        ip = randomIP.ip;
    }
    
    WCBuiltinIP *randomBuiltinIp = [WCBuiltinIP getARandomLongBuiltinIP];
    if (randomBuiltinIp != nil) {
        ip = randomBuiltinIp.ip;
        port = [NSString stringWithFormat:@"%d", randomBuiltinIp.port];
    }
    
    FastSocket *client = [[FastSocket alloc] initWithHost:ip andPort:port]; //long.weixin.qq.com 58.247.204.141:443 //163.177.81.141 //121.51.130.111:80  121.51.130.111
    if ([client connect])
    {
        LogDebug(@"FastSocket Connected To Server: %@:%@", ip, port);
        _client = client;
        [self InitLongLinkMMTLS];
        [self readData];
    }
    else
    {
        LogError(@"FastSocket Can Not Connect.");
    }
}

- (void)restart
{
    if ([_client close]) {
        _writeSeq = 1;
        _readSeq = 1;
        _serverHelloData = [NSMutableData data];
        
        [self start];
    }
}

- (void)InitLongLinkMMTLS
{
    _clientHello = [ClientHello new];
    NSData *clientHelloData = [_clientHello CreateClientHello];
    [self _sendData:clientHelloData];
}

#pragma mark - Write Read Data
- (void)_sendData:(NSData *)sendData
{
    dispatch_async(_writeSerialQueue, ^{
        long sent = [self.client sendBytes:[sendData bytes] count:[sendData length]];
        if (sent == sendData.length)
        {
//            LogDebug(@"FastSocket Send all the Data, Len: %ld", sent);
        }
        else
        {
//            LogError(@"FastSocket Send Only %ld Bytes.", sent);
        }
    });
}

- (void)readData
{
    dispatch_async(_readSerialQueue, ^{
        while (1)
        {
            NSData *dataPackage = [self ReadMMTLSDataPkg];
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
        //LogInfo(@"Read 5 bytes Head.");
    }

    uint32_t payloadLength = [header toInt16ofRange:NSMakeRange(3, 2) SwapBigToHost:YES];
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
        return [payload copy];
    }
    else
    {
        LogError(@"Read Payload not match expect.");
        return nil;
    }
}

#pragma mark - Deal Server Hello

- (BOOL)hasPskFile {
    return [[NSFileManager defaultManager] fileExistsAtPath:_pskFilePath];
}

- (void)onReviceServerHello:(ServerHello *)serverHello
{
    NSData *hashPart1 = [_clientHello getHashPart];
    NSData *hashPart2 = [serverHello getHashPart];
    NSMutableData *hashData = [NSMutableData dataWithData:hashPart1];
    [hashData appendData:hashPart2];
    NSData *HandshakeKeyExpansionHash = [WC_SHA256 sha256:hashData];

    NSData *serverPublicKey = [serverHello getServerPublicKey];
    NSData *localPriKey = [_clientHello getLocal1stPrikey];

    NSData *EphemeralSecret = [WCECDH DoEcdh2:415 ServerPubKey:serverPublicKey LocalPriKey:localPriKey];

    NSMutableData *HandshakeKeyExpansionHashInfo = [NSMutableData dataWithData:[@"handshake key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [HandshakeKeyExpansionHashInfo appendData:HandshakeKeyExpansionHash];

    NSData *HandShakeKey = [WC_HKDF HKDF_Expand:EphemeralSecret Info:[HandshakeKeyExpansionHashInfo copy]];
    KeyPair *keyPair = [[KeyPair alloc] initWithData:HandShakeKey];

    /******************************** 开始解密PSK ****************************************/
    // Part1 decrypt
    NSData *part1 = [serverHello getPart1];

    NSMutableData *aad1 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[part1 length] flip:NO]];

    NSData *readIV1 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始。
    NSData *plainText1 = [WC_AesGcm128 aes128gcmDecrypt:part1 aad:[aad1 copy] key:keyPair.readKEY ivec:readIV1];

    // Part2 decrypt
    NSData *part2 = [serverHello getPart2];

    NSMutableData *aad2 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad2 appendData:[NSData packInt32:(int32_t)[part2 length] flip:NO]];

    NSData *readIV2 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始，每次+1；
    NSData *plainText2 = [WC_AesGcm128 aes128gcmDecrypt:part2 aad:[aad2 copy] key:keyPair.readKEY ivec:readIV2];
    
    {
        NSData *psk1 = [plainText2 subdataWithRange:NSMakeRange(9, 100)];
        
        NSData *hashDataTmp = hashData;
        hashDataTmp = [hashDataTmp addDataAtTail:plainText1];
        NSData *hashResult = [WC_SHA256 sha256:hashDataTmp];

        // 需要密钥扩展一次结果。
        NSMutableData *info222 = [NSMutableData dataWithData:[@"PSK_ACCESS" dataUsingEncoding:NSUTF8StringEncoding]];
        [info222 appendData:hashResult];
        NSData *ResumptionSecret = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:info222]; //expanded secret
        
        if ([self hasPskFile]) {
            // psk fresh 第二次连接
            NSMutableData *info333 = [NSMutableData dataWithData:[@"PSK_REFRESH" dataUsingEncoding:NSUTF8StringEncoding]];
            [info333 appendData:hashResult];
//            ResumptionSecret = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:info333]; //expanded secret
        }
        
        [_delegate onLongLinkHandShakeFinishedWithPSK:psk1 resumptionSecret:ResumptionSecret];
        
        ////
        
        // save psk2
        NSData *psk2 = [plainText2 subdataWithRange:NSMakeRange(9 + 100, [plainText2 length] - 9 - 100)];
        psk2 = [psk2 subdataWithRange:NSMakeRange(0x30 - 4, [psk2 length] - 0x30 + 4)];
        [psk2 writeToFile:_pskFilePath atomically:YES];
    }

    // Part3 decrypt
    NSData *part3 = [serverHello getPart3];

    NSMutableData *aad3 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad3 appendData:[NSData packInt32:(int32_t)[part3 length] flip:NO]];

    NSData *readIV3 = [WC_Hex IV:keyPair.readIV XORSeq:_readSeq++]; //序号从1开始，每次+1；
    NSData *plainText3 = [WC_AesGcm128 aes128gcmDecrypt:part3 aad:[aad3 copy] key:keyPair.readKEY ivec:readIV3]; //[:20]字节应该等于server finished hmac256 用于校验？
    
    /******************************** 解密PSK结束 (OK) ****************************************/

    /******************************** 长连接 加密KEY & IV 的计算 **************************/
    //1.需要第二部分解密结果的hash 结果。
    NSMutableData *md = [NSMutableData dataWithData:hashData];
    [md appendData:plainText1];
    [md appendData:plainText2];
    NSData *ApplicationDataKeyExpansionHash = [WC_SHA256 sha256:md];
    // 需要密钥扩展一次结果。
    NSMutableData *ApplicationDataKeyExpansion = [NSMutableData dataWithData:[@"application data key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [ApplicationDataKeyExpansion appendData:ApplicationDataKeyExpansionHash];

    //2. secret
    NSMutableData *ExpandedSecret = [NSMutableData dataWithData:[@"expanded secret" dataUsingEncoding:NSUTF8StringEncoding]];
    [ExpandedSecret appendData:ApplicationDataKeyExpansionHash];

    NSData *ExpandSecretKey = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:ExpandedSecret]; //expanded secret
    NSData *ApplicationDataKey = [WC_HKDF HKDF_Expand:ExpandSecretKey Info:[ApplicationDataKeyExpansion copy]]; //长连接 加解密 key iv 生成。 //application data key expansion

    //    DLog(@"ApplicationDataKey", ApplicationDataKey);

    /******************************** 长连接 加密KEY & IV 的计算（OK） **************************/

    /******************************** 心跳请求组包 **************************/

    // 1. 心跳请求第一部分数据。
    NSData *clientFinished = [@"client finished" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ClientFinishedKey = [WC_HKDF HKDF_Expand_Prk2:EphemeralSecret Info:clientFinished]; //OK //client finished

    NSData *hmacResult = [WC_HmacSha256 HmacSha256WithKey:ClientFinishedKey data:ApplicationDataKeyExpansionHash]; //OK

    NSMutableData *clientFinishedData = [NSMutableData dataWithHexString:@"00000023140020"];
    [clientFinishedData appendData:hmacResult];

    NSData *aadddd = [NSData dataWithHexString:@"000000000000000116F1030037"];

    NSData *writeIV1 = [WC_Hex IV:keyPair.writeIV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    NSData *clientFinishedCipherData = [WC_AesGcm128 aes128gcmEncrypt:clientFinishedData aad:aadddd key:keyPair.writeKEY ivec:writeIV1];
    clientFinishedCipherData = [clientFinishedCipherData addDataAtHead:[NSData dataWithHexString:@"16F1030037"]];
    
    // 2. 心跳包数据。
    KeyPair *keyPair2 = [[KeyPair alloc] initWithData:ApplicationDataKey];
    NSData *writeIV = [WC_Hex IV:keyPair2.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"000000000000000217F1030020"];

    _longlinkKeyPair = keyPair2;
    NSData *heart = [long_pack pack:-1 cmdId:CMDID_NOOP_REQ shortData:nil];
    NSData *heartbeatCipherData = [WC_AesGcm128 aes128gcmEncrypt:heart aad:aadd key:keyPair2.writeKEY ivec:writeIV];

    heartbeatCipherData =  [heartbeatCipherData addDataAtHead:[NSData dataWithHexString:@"17f1030020"]];
    // 3. 心跳包加一块.
    NSData *sendData = [clientFinishedCipherData addDataAtTail:heartbeatCipherData];
    [self _sendData:sendData];
}

#pragma mark - MMTLS

- (void)sendData:(NSData *)sendData
{
    NSData *writeIV = [WC_Hex IV:_longlinkKeyPair.writeIV XORSeq:_writeSeq++];
    NSData *aadd = [NSData dataWithHexString:@"00000000000000"];
    aadd = [aadd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) (_writeSeq - 1)]]];
    aadd = [[aadd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int32_t)([sendData length] + 0x10) flip:YES]]; //0x10 aad len

    NSData *mmtlsData = [WC_AesGcm128 aes128gcmEncrypt:sendData aad:aadd key:_longlinkKeyPair.writeKEY ivec:writeIV];

    NSData *sendMsgData = [[NSData dataWithHexString:@"17F103"] addDataAtTail:[NSData packInt16:(int16_t)([sendData length] + 0x10) flip:YES]];
    sendMsgData = [sendMsgData addDataAtTail:mmtlsData];

    [self _sendData:sendMsgData];
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

#pragma mark - UnPackLong

- (void)onReceive:(NSData *)data
{
    NSData *plainText = [self mmtlsDeCryptData:data];
    [_delegate onRcvData:plainText];
}

@end
