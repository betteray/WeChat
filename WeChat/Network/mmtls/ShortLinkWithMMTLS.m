//
//  ShortLinkWithMMTLS.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkWithMMTLS.h"
#import "NSData+GenRandomData.h"

#import "Cryption/WC_SHA256.h"
#import "Cryption/WC_HKDF.h"
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
@property (nonatomic, strong) NSData *timeStampData;

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
//        _clientRandom = [NSData dataWithHexString:@"AABA156458E600D96C8658A439D9173FA780378041E64714EF5E539184D17E79"];
        _decryptedPart2 = decryptedPart2;
        _resumptionSecret = resumptionSecret;
        _httpData = httpData;
        
        NSUInteger timeStamp = [[NSDate date] timeIntervalSince1970];
        _timeStampData = [NSData packInt32:(int32_t) timeStamp flip:YES];
//        _timeStampData = [NSData dataWithHexString:@"5D78D74B"];
    }
    return self;
}

- (NSData *)getHashPart
{
    NSMutableData *clientHelloData = [[NSData dataWithHexString:@"0000009D0103F10100A8"] mutableCopy];
    [clientHelloData appendData:_clientRandom];                                              //client random
    
    [clientHelloData appendData:_timeStampData];         //time
    [clientHelloData appendData:[NSData dataWithHexString:@"0000006F010000006A000F01000000"]]; //fix
    [clientHelloData appendData:_decryptedPart2];
    
    _clientHelloData = [clientHelloData copy];

    return _clientHelloData;
}

- (NSData *)getSendData
{
    NSData *hashPart = [self getHashPart];
    NSData *hashResult = [WC_SHA256 sha256:hashPart];
    NSData *info = [NSData dataWithData:[@"early data key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *expandParam2 = [info addDataAtTail:hashResult];
    NSData *expandParam1 = _resumptionSecret;
    
    NSData *expandResult = nil;
    [WC_HKDF HKDF_Expand_Prk3:expandParam1 Info:expandParam2 outOkm:&expandResult]; //短链接加密key 及 iv 。
    ShortLinkKey *shortlinkWriteKey = [[ShortLinkKey alloc] initWithData:expandResult];
    
    NSData *fixData = [NSData dataWithHexString:@"00000010080000000B01000000060012"];
    fixData = [fixData addDataAtTail:_timeStampData]; // （固定 + 时间戳）
    
    _clientHashPart = [_clientHelloData addDataAtTail:fixData];
    
    NSData *writeIV = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    
    NSData *aadddd = [NSData dataWithHexString:@"00000000000000"];
    aadddd = [aadddd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) (_writeSeq - 1)]]];
    aadddd = [[aadddd addDataAtTail:[NSData dataWithHexString:@"19F103"]] addDataAtTail:[NSData packInt16:(int32_t)([fixData length] + 0x10) flip:YES]]; //0x10 aad len
    
    NSData *encryptedPart1 = [WC_AesGcm128 aes128gcmEncrypt:fixData aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];          //第一次加密
    
    NSData *postData = [NSData dataWithHexString:@"19F103"];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[hashPart length] flip:YES]];
    postData = [postData addDataAtTail:hashPart];
    
    postData = [postData addDataAtTail:[NSData dataWithHexString:@"19F103"]];
    postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[encryptedPart1 length] flip:YES]];
    postData = [postData addDataAtTail:encryptedPart1];
    
    ////////
    
    NSUInteger block = [_httpData length] / 0x8000 + 1;
    
    NSUInteger startPos = 0;
    for (NSUInteger index = 0; index < block; index ++) {
        
        NSUInteger sendCnt = 0;
        if (_httpData.length - startPos > 0x8000) {
            sendCnt = 0x8000; // 没次加密这么多
        } else {
            sendCnt = _httpData.length - startPos; // 加密剩余的
        }
        
        NSData *subData = [_httpData subdataWithRange:NSMakeRange(startPos, sendCnt)];
        writeIV = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
        aadddd = [NSData dataWithHexString:@"00000000000000"];
        aadddd = [aadddd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) (_writeSeq - 1)]]];
        aadddd = [[aadddd addDataAtTail:[NSData dataWithHexString:@"17F103"]] addDataAtTail:[NSData packInt16:(int32_t)([subData length] + 0x10) flip:YES]]; //0x10 aad len
        
        NSData *encryptedPart2 = [WC_AesGcm128 aes128gcmEncrypt:subData aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];        //第二次加密 http 明文流量

        postData = [postData addDataAtTail:[NSData dataWithHexString:@"17F103"]];
        postData = [postData addDataAtTail:[NSData packInt16:(int16_t)[encryptedPart2 length] flip:YES]];
        postData = [postData addDataAtTail:encryptedPart2];
        
        startPos += sendCnt;
    }
    
    //////
    
    NSData *plainTextData3 = [NSData dataWithHexString:@"00000003000101"]; // 第三次固定内容
    writeIV = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_writeSeq++]; //序号从1开始，每次+1；
    
    aadddd = [NSData dataWithHexString:@"00000000000000"];
    aadddd = [aadddd addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2X", (unsigned int) (_writeSeq - 1)]]];
    aadddd = [[aadddd addDataAtTail:[NSData dataWithHexString:@"15F103"]] addDataAtTail:[NSData packInt16:(int32_t)([plainTextData3 length] + 0x10) flip:YES]]; //0x10 aad len
    
    NSData *encryptedPart3 = [WC_AesGcm128 aes128gcmEncrypt:plainTextData3 aad:aadddd key:shortlinkWriteKey.KEY ivec:writeIV];   //第三次解密内容固定
    
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
    NSData *hashResult = [WC_SHA256 sha256:clientHashPart];
    
    NSMutableData *info = [NSMutableData dataWithData:[@"handshake key expansion" dataUsingEncoding:NSUTF8StringEncoding]];
    [info appendData:hashResult];
    
    NSData *expandResult = nil;
    [WC_HKDF HKDF_Expand_Prk3:_resumptionSecret Info:info outOkm:&expandResult];
    ShortLinkKey *shortlinkWriteKey = [[ShortLinkKey alloc] initWithData:expandResult]; //解密key iv
    
    // 第一部分
    NSData *encryptedPart1 = [response getPart1];
    NSMutableData *aad1 = [[NSData dataWithHexString:@"000000000000000116F103"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[encryptedPart1 length] flip:NO]];
    NSData *readIV1 = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_readSeq++]; //序号从1开始。
    NSData *plainText1 = [WC_AesGcm128 aes128gcmDecrypt:encryptedPart1 aad:[aad1 copy] key:shortlinkWriteKey.KEY ivec:readIV1];
    
    // 第二部分 存在多个片段，需分别解密然后拼装。
    aad1 = [[NSData dataWithHexString:@"000000000000000217F10301"] mutableCopy];
    NSMutableData *plainResponseText = [NSMutableData data];
    NSMutableArray<NSData *> *dataSegs = [response getDataSegs];
    for (int i=0; i<dataSegs.count; i++) {
        NSData *encrypedDataSeg = dataSegs[i];
        [aad1 appendData:[NSData packInt32:(int32_t)[encrypedDataSeg length] flip:NO]];
        readIV1 = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_readSeq++]; //序号从1开始。
        NSData *plainDataSeg = [WC_AesGcm128 aes128gcmDecrypt:encrypedDataSeg aad:[aad1 copy] key:shortlinkWriteKey.KEY ivec:readIV1];
        [plainResponseText appendData:plainDataSeg];
    }
    
    // 第三部分
    NSData *encrypedPart3 = [response getPart3];
    aad1 = [[NSData dataWithHexString:@"000000000000000317F10301"] mutableCopy];
    [aad1 appendData:[NSData packInt32:(int32_t)[encrypedPart3 length] flip:NO]];
    readIV1 = [WC_Hex IV:shortlinkWriteKey.IV XORSeq:_readSeq++]; //序号从1开始。
    NSData *plainText3 = [WC_AesGcm128 aes128gcmDecrypt:encrypedPart3 aad:[aad1 copy] key:shortlinkWriteKey.KEY ivec:readIV1];

    return plainResponseText;
}

@end
