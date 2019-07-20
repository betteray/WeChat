//
//  UtilsJni.m
//  WeChat
//
//  Created by ysh on 2019/7/1.
//  Copyright © 2019 ray. All rights reserved.
//

#import "UtilsJni.h"
#import "WCECDH.h"
#import "WC_SHA256.h"
#import "NSData+GenRandomData.h"
#import "NSData+Compression.h"
#import "WC_AesGcm128.h"
#import "WC_HKDF.h"
#import "Varint128.h"
#import "UtileJni.pbobjc.h"

#define LOCAL_PRIKEY @"0495BC6E5C1331AD172D0F35B1792C3CE63F91572ABD2DD6DF6DAC2D70195C3F6627CCA60307305D8495A8C38B4416C75021E823B6C97DFFE79C14CB7C3AF8A586"

@interface UtilsJni ()

@property(nonatomic, strong) NSData *prikey;
@property(nonatomic, strong) NSData *pubkey;

@property(nonatomic, strong) NSData *receivedHashData;
@property(nonatomic, strong) NSData *plainData;
@end

@implementation UtilsJni

- (instancetype)init {
    self  = [super init];
    if (self) {
        
        NSData *prikey = nil;
        NSData *pubkey = nil;
        
        if ([WCECDH GenEcdhWithNid:415 priKey:&prikey pubKeyData:&pubkey]) {
            self.prikey = prikey;
            self.pubkey = pubkey;
        }
    }
    
    return self;
}


- (NSData *)HybridEcdhEncrypt:(NSData *)plainData {
    _plainData = plainData;
    NSData *localPriKey = [NSData dataWithHexString:LOCAL_PRIKEY];
    NSData *ecdhResult = [WCECDH DoEcdh2:415 ServerPubKey:localPriKey LocalPriKey:_prikey];
    
    NSData *hashData = [NSData dataWithHexString:@"31"]; //1
    hashData = [hashData addDataAtTail:[NSData dataWithHexString:@"343135"]]; //415
    hashData = [hashData addDataAtTail:_pubkey];
    NSData *hashDataResult = [WC_SHA256 sha256:hashData];
    
    NSData *ikmData = [NSData GenRandomDataWithSize:32]; //random
    NSData *compressedData = [ikmData dataByDeflating];
    NSData *ivData = [NSData dataWithHexString:[@"63612D5D FA042DD1 877F70B9"
                                                stringByReplacingOccurrencesOfString:@" "
                                                withString:@""]];
    
    NSData *encryptedData = [WC_AesGcm128 aes192gcmEncrypt:compressedData
                                                       aad:hashDataResult
                                                       key:[ecdhResult subdataWithRange:NSMakeRange(0, 24)]
                                                      ivec:ivData];

    NSData *saltData = [NSData dataWithHexString:[@"73656375 72697479 2068646B 66206578 70616E64"
                                                  stringByReplacingOccurrencesOfString:@" "
                                                  withString:@""]]; //固定字符串: security hdkf expand
    unsigned char okm[56];
    [WC_HKDF HKDF_salt:(unsigned char *)[saltData bytes]
              salt_len:[saltData length]
                   ikm:(const unsigned char *)[ikmData bytes]
               ikm_len:[ikmData length]
                  info:(const unsigned char *)[hashDataResult bytes]
              info_len:[hashDataResult length]
                   okm:okm
               okm_len:56];
    NSData *hkdfData = [NSData dataWithBytes:okm length:56];
    
    _receivedHashData = [hkdfData subdataWithRange:NSMakeRange(24, [hkdfData length] - 24)];
    
    // ============= part 2, protobuf 加密 =============
    
    NSData *hashData2 = [NSData dataWithHexString:@"31"]; //1
    hashData2 = [hashData2 addDataAtTail:[NSData dataWithHexString:@"343135"]]; //415
    hashData2 = [hashData2 addDataAtTail:_pubkey];
    hashData2 = [hashData2 addDataAtTail:encryptedData];

    NSData *hashDataResult2 = [WC_SHA256 sha256:hashData2];
    NSData *compressedData2 = [plainData dataByDeflating];

    NSData *ivData2 = [NSData dataWithHexString:[@"57BC4BC5 C31C7C67 5C3F794B"
                                                 stringByReplacingOccurrencesOfString:@" "
                                                 withString:@""]]; // ？
    
    NSData *aad = [hkdfData subdataWithRange:NSMakeRange(0, 24)];
    NSData *encryptedData2 = [WC_AesGcm128 aes192gcmEncrypt:compressedData2
                                                        aad:hashDataResult2
                                                        key:aad
                                                       ivec:ivData2];
    
    UtileJniECDHKey *ecdhKey = [UtileJniECDHKey new];
    ecdhKey.nid = 415;
    ecdhKey.key = _pubkey;
    
    UtileJniSendPackage *package = [UtileJniSendPackage new];
    package.tag1 = 1;
    package.ecdhkey = ecdhKey;
    package.tag4 = [NSData data];
    package.data1 = encryptedData;
    package.data2 = encryptedData2;
    
    return [package data];
}

- (NSData *)HybridEcdhDecrypt:(NSData *)encryptedData {

    UtileJniReceivePackage *package = [[UtileJniReceivePackage alloc] initWithData:encryptedData error:nil];
    
    NSData *ecdhResult = [WCECDH DoEcdh2:package.ecdhkey.nid ServerPubKey:package.ecdhkey.key LocalPriKey:_prikey];
    
    _receivedHashData = [_receivedHashData addDataAtTail:_plainData];
    _receivedHashData = [_receivedHashData addDataAtTail:[NSData dataWithHexString:@"343135"]];
    _receivedHashData = [_receivedHashData addDataAtTail:package.ecdhkey.key];
    _receivedHashData = [_receivedHashData addDataAtTail:[NSData dataWithHexString:@"31"]];

    NSData *hashDataResult = [WC_SHA256 sha256:_receivedHashData];
    
    NSData *ivData = [package.tag3 subdataWithRange:NSMakeRange([package.tag3 length] - 28, 12)];
    NSData *encrypedData = [package.tag3 subdataWithRange:NSMakeRange(0, [package.tag3 length]-28)];
    NSData *plainData = [WC_AesGcm128 aes192gcmDecrypt:encrypedData
                                                   aad:hashDataResult
                                                   key:[ecdhResult subdataWithRange:NSMakeRange(0, 24)]
                                                  ivec:ivData];
    
    return [plainData dataByInflatingWithError:nil];
}

@end
