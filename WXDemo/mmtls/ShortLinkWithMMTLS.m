//
//  ShortLinkWithMMTLS.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkWithMMTLS.h"
#import "NSData+GenRandomData.h"

#import "WX_SHA256.h"
#import "WX_HKDF.h"
#import "ShortLinkKey.h"

#import "MMTLSShortLinkResponse.h"

@interface ShortLinkWithMMTLS ()

@property (nonatomic, strong) NSData *clientRandom;
@property (nonatomic, strong) NSData *clientHelloData;

@property (nonatomic, strong) NSData *decryptedPart2;

@property (nonatomic, strong) NSData *resumptionSecret;

@property (nonatomic, assign) NSInteger writeSeq;
@property (nonatomic, assign) NSInteger readSeq;

@property (nonatomic, strong) NSData *httpData;

@property (nonatomic, strong) NSData *clientHashPart;

@end

@implementation ShortLinkWithMMTLS

- (instancetype)initWithDecryptedPart2:(NSData *)decryptedPart2
                      resumptionSecret:(NSData *)resumptionSecret
                              httpData:(NSData *)httpData
{
    self = [super init];
    if (self) {
        _writeSeq = 1;
        _readSeq = 1;
        
        _clientRandom = [NSData GenRandomDataWithSize:32];
        _decryptedPart2 = decryptedPart2;
        _resumptionSecret = resumptionSecret;
        _httpData = httpData;
    }
    return self;
}

- (NSData *)getHashPart
{
    NSMutableData *clientHelloData = [[NSData dataWithHexString:@"0000009D0103F10100A8"] mutableCopy];
    [clientHelloData appendData:_clientRandom];                                              //client random
    
    NSUInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    NSData *timeStampData = [NSData packInt32:(int32_t) timeStamp flip:NO];
    [clientHelloData appendData:timeStampData];         //time
    [clientHelloData appendData:[NSData dataWithHexString:@"0000006F010000006A000F01000000"]]; //fix
    [clientHelloData appendData:_decryptedPart2];
    
    _clientHelloData = [clientHelloData copy];
    DLog(@"Client Hello", _clientHelloData);

    return _clientHelloData;
}

- (NSData *)getSendData
{
    NSData *hashPart = [self getHashPart];
    NSData *hashResult = [WX_SHA256 sha256:hashPart];
    NSData *info = [NSData dataWithData:[@"early data key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *expandParam2 = [info addDataAtTail:hashResult];
    NSData *expandParam1 = _resumptionSecret;
    
    NSData *expandResult = nil;
    [WX_HKDF HKDF_Expand_Prk3:expandParam1 Info:expandParam2 outOkm:&expandResult]; //短链接加密key 及 iv 。
    ShortLinkKey *shortlinkWriteKey = [[ShortLinkKey alloc] initWithData:expandResult];
    
    NSData *fixData = [NSData dataWithHexString:@"00000010080000000B01000000060012"];
    NSUInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    NSData *timeStampData = [NSData packInt32:(int32_t) timeStamp flip:NO];
    fixData = [fixData addDataAtTail:timeStampData]; // （固定 + 时间戳）
    
    _clientHashPart = [_clientHelloData addDataAtTail:fixData];
    
    NSData *writeIV = [WX_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    NSData *encryptedPart1 = nil;
    NSData *aadddd = [NSData dataWithHexString:@"000000000000000119F1030024"];
    [WX_AesGcm128 aes128gcmEncrypt:fixData ciphertext:&encryptedPart1 aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];          //第一次加密
    
    NSData *postData = [NSData dataWithHexString:@"19F103"];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[hashPart length] flip:YES]];
    postData = [postData addDataAtTail:hashPart];
    
    postData = [postData addDataAtTail:[NSData dataWithHexString:@"19F103"]];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[encryptedPart1 length] flip:YES]];
    postData = [postData addDataAtTail:encryptedPart1];
    
    writeIV = [WX_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    NSData *encryptedPart2 = nil;
    aadddd = [NSData dataWithHexString:@"000000000000000217F1030251"];
    [WX_AesGcm128 aes128gcmEncrypt:_httpData ciphertext:&encryptedPart2 aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];        //第二次加密 http 明文流量

    postData = [postData addDataAtTail:[NSData dataWithHexString:@"17F103"]];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[encryptedPart2 length] flip:YES]];

    postData = [postData addDataAtTail:encryptedPart2];
    
    NSData *plainTextData3 = [NSData dataWithHexString:@"00000003000101"]; // 第三次固定内容
    writeIV = [WX_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    NSData *encryptedPart3 = nil;
    aadddd = [NSData dataWithHexString:@"000000000000000315F1030017"];
    [WX_AesGcm128 aes128gcmEncrypt:plainTextData3 ciphertext:&encryptedPart3 aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];   //第三次解密内容固定
    
    postData = [postData addDataAtTail:[NSData dataWithHexString:@"15F103"]];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[encryptedPart3 length] flip:YES]];
    postData = [postData addDataAtTail:encryptedPart3];

    return postData;
}

//TODO 数据校验Hmac
- (NSData *)receiveData:(MMTLSShortLinkResponse *)response
{
    NSData *clientHashPart = _clientHashPart;
    NSData *serverHashPart = [response getHashPart];
    clientHashPart = [clientHashPart addDataAtTail:serverHashPart];
    NSData *hashResult = [WX_SHA256 sha256:clientHashPart];
    
    NSMutableData *info = [NSMutableData dataWithData:[@"handshake key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [info appendData:hashResult];
    
    NSData *expandResult = nil;
    [WX_HKDF HKDF_Expand_Prk3:_resumptionSecret Info:info outOkm:&expandResult];
    ShortLinkKey *shortlinkWriteKey = [[ShortLinkKey alloc] initWithData:expandResult]; //解密key iv
    
    // 第一部分
    NSData *encryptedPart1 = [response getPart1];
    
    NSMutableData *aad1 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[encryptedPart1 length] flip:NO]];
    
    NSData *readIV1 = [WX_Hex IV:shortlinkWriteKey.IV XORSeq:_readSeq++]; //序号从1开始。
    
    DLog(@"after XOR readIV 1", readIV1);
    
    NSData *plainText1 = nil;
    [WX_AesGcm128 aes128gcmDecrypt:encryptedPart1 plaintext:&plainText1 aad:[aad1 copy] key:shortlinkWriteKey.KEY ivec:readIV1];
    
    DLog(@"decrypted part1", plainText1);   //好像校验数据用。
    
    // 第二部分
    NSData *encrypedPart2 = [response getPart2];
    
    aad1 = [[NSData dataWithHexString:@"000000000000000217F10301"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[encrypedPart2 length] flip:NO]];
    
    readIV1 = [WX_Hex IV:shortlinkWriteKey.IV XORSeq:_readSeq++]; //序号从1开始。
    
    DLog(@"after XOR readIV 1", readIV1);
    
    NSData *plainText2 = nil;
    [WX_AesGcm128 aes128gcmDecrypt:encrypedPart2 plaintext:&plainText2 aad:[aad1 copy] key:shortlinkWriteKey.KEY ivec:readIV1];
    
    DLog(@"decrypted part2", plainText2);
    
    return plainText2;
}

@end
