//
//  ClientHello.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ClientHello.h"
#import "NSData+Util.h"
#import "NSData+GenRandomData.h"
#import "WCECDH.h"

@interface ClientHello ()

@property (nonatomic, strong) NSData *clientRandom;

@property (nonatomic, strong) NSData *pubkey1;
@property (nonatomic, strong) NSData *prikey1;

@property (nonatomic, strong) NSData *pubkey2;
@property (nonatomic, strong) NSData *prikey2;

@property (nonatomic, strong) NSData *psk2Data;

@property (nonatomic, strong) NSData *clientHelloData;

@end

@implementation ClientHello

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _clientRandom = [NSData GenRandomDataWithSize:32];
        NSData *pubkey1;
        NSData *prikey1;
        BOOL ret1 = [WCECDH GenEcdhWithNid:415 priKey:&prikey1 pubKeyData:&pubkey1];
        if (ret1)
        {
            _prikey1 = prikey1;
            _pubkey1 = pubkey1;
        }

        NSData *pubkey2;
        NSData *prikey2;
        BOOL ret2 = [WCECDH GenEcdhWithNid:415 priKey:&prikey2 pubKeyData:&pubkey2];
        if (ret2)
        {
            _prikey2 = prikey2;
            _pubkey2 = pubkey2;
        }
    }

    return self;
}

- (BOOL)hasLocalPsk {
    NSString *pskFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"psk.key"];
    return [[NSFileManager defaultManager] fileExistsAtPath:pskFilePath];
}

- (NSData *)CreateClientHello
{
    if (!_clientHelloData)
    {
        
        if ([self hasLocalPsk]) {
            NSString *pskFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"psk.key"];
            _psk2Data = [NSData dataWithContentsOfFile:pskFilePath];
            LogVerbose(@"Got PSK File.");
            
            NSMutableData *clientHelloData = [[NSData dataWithHexString:@"16F1030165"] mutableCopy]; //mmtls head [16F10300D4: 0xD4(212)为后面包长度]
            [clientHelloData appendData:[NSData dataWithHexString:@"000001610103F102C02B00A8"]];         //fix
            [clientHelloData appendData:_clientRandom];                                              //client random
            
            NSUInteger timeStamp = (NSUInteger) [[NSDate date] timeIntervalSince1970];
            NSData *timeStampData = [NSData packInt32:(int32_t) timeStamp flip:YES];
            [clientHelloData appendData:timeStampData];         //time
            
            // begin add
            [clientHelloData appendData:[NSData dataWithHexString:@"00000131020000008B000F01000000840200278D00000000"]]; //fix
            [clientHelloData appendData:_psk2Data];
            [clientHelloData appendData:[NSData dataWithHexString:@"0000009D001002"]];
            // end add
            [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000010041"]]; //fix 0x41 = 65 pubkey len, 00000001 第一个序号（字段）， 0x47 = 0x41 + 6
            [clientHelloData appendData:_pubkey1];                                           //pubkey
            
            [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000020041"]]; //fix 0x41 = 65 pubkey len, 00000001 第二个序号（字段），0x47 = 0x41 + 6
            [clientHelloData appendData:_pubkey2];                                           //pubkey
            
            [clientHelloData appendData:[NSData dataWithHexString:@"00000001"]]; //fix
            
            _clientHelloData = [clientHelloData copy];
            
        } else {
            NSMutableData *clientHelloData = [[NSData dataWithHexString:@"16F10300D4"] mutableCopy]; //mmtls head [16F10300D4: 0xD4(212)为后面包长度]
            [clientHelloData appendData:[NSData dataWithHexString:@"000000D00103F101C02B"]];         //fix
            [clientHelloData appendData:_clientRandom];                                              //client random
            
            NSUInteger timeStamp = (NSUInteger) [[NSDate date] timeIntervalSince1970];
            NSData *timeStampData = [NSData packInt32:(int32_t) timeStamp flip:YES];
            [clientHelloData appendData:timeStampData];         //time
            [clientHelloData appendData:[NSData dataWithHexString:@"000000A2010000009D001002"]]; //fix
            
            [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000010041"]]; //fix 0x41 = 65 pubkey len, 00000001 第一个序号（字段）， 0x47 = 0x41 + 6
            [clientHelloData appendData:_pubkey1];                                           //pubkey
            
            [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000020041"]]; //fix 0x41 = 65 pubkey len, 00000001 第二个序号（字段），0x47 = 0x41 + 6
            [clientHelloData appendData:_pubkey2];                                           //pubkey
            
            [clientHelloData appendData:[NSData dataWithHexString:@"00000001"]]; //fix
            
            _clientHelloData = [clientHelloData copy];
        }
    }

    return _clientHelloData;
}

- (NSData *)getHashPart
{
    NSData *header = [NSData dataWithHexString:@"16F10300D4"];
    if ([self hasLocalPsk]) {
        return [_clientHelloData subdataWithRange:NSMakeRange([header length], 0x165)]; // 取包体内容
    } else {
        return [_clientHelloData subdataWithRange:NSMakeRange([header length], 0xD4)]; // 取包体内容
    }
}

- (NSData *)getLocal1stPrikey
{
    return _prikey1;
}

@end
