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
#import "ECDH.h"

@interface ClientHello ()

@property (nonatomic, strong) NSData *clientRandom;

@property (nonatomic, strong) NSData *pubkey1;
@property (nonatomic, strong) NSData *prikey1;

@property (nonatomic, strong) NSData *pubkey2;
@property (nonatomic, strong) NSData *prikey2;

@property (nonatomic, strong) NSData *clientHelloData;

@end

@implementation ClientHello

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _clientRandom = [NSData GenRandomDataWithSize:32];
//        _clientRandom = [NSData dataWithHexString:@"BFBB3304CE294BF241A754996B85D0D91DB37F4D9B0656AA3AB635C48545B72A"];
        NSData *pubkey1;
        NSData *prikey1;
        BOOL ret1 = [ECDH GenEcdhWithNid:415 priKey:&prikey1 pubKeyData:&pubkey1];
        if (ret1)
        {
            _prikey1 = prikey1;
            _pubkey1 = pubkey1;
        }

        NSData *pubkey2;
        NSData *prikey2;
        BOOL ret2 = [ECDH GenEcdhWithNid:415 priKey:&prikey2 pubKeyData:&pubkey2];
        if (ret2)
        {
            _prikey2 = prikey2;
            _pubkey2 = pubkey2;
        }
        
//        _prikey1 = [NSData dataWithHexString:@"307702010104204B5DF336CEEAAECD52F44983D05ECB16E063134B48214A30279ABC0DE6D1F4ACA00A06082A8648CE3D030107A144034200040683FFB4280A0061018227C215501363CBE26E99A1222C56A43C5337C4F625CAA3A9102F969235B1775EB948D47A84C56AD3E109C1AE2F748B72E885A9E41A41"];
//        _pubkey1 = [NSData dataWithHexString:@"040683FFB4280A0061018227C215501363CBE26E99A1222C56A43C5337C4F625CAA3A9102F969235B1775EB948D47A84C56AD3E109C1AE2F748B72E885A9E41A41"];
//
//        _prikey2 = [NSData dataWithHexString:@"307702010104205A6AADCC8D11CEFC1FFAA2E1B6C06362859F8BF3C7A02053871F669A7109DEABA00A06082A8648CE3D030107A144034200042BFC62671C1C977B3C51678D386FEC388C14A2EEE439062106B6603C305F2C9AC07147D33790658F06876BB158D95531FD3210784E2CDF41707846907A03A17C"];
//        _pubkey2 = [NSData dataWithHexString:@"042BFC62671C1C977B3C51678D386FEC388C14A2EEE439062106B6603C305F2C9AC07147D33790658F06876BB158D95531FD3210784E2CDF41707846907A03A17C"];
    }

    return self;
}

- (NSData *)CreateClientHello
{
    if (!_clientHelloData)
    {
        NSMutableData *clientHelloData = [[NSData dataWithHexString:@"16F10300D4"] mutableCopy]; //mmtls head [16F10300D4: 0xD4为后面包长度]
        [clientHelloData appendData:[NSData dataWithHexString:@"000000D00103F101C02B"]];         //fix
        [clientHelloData appendData:_clientRandom];                                              //client random

        NSUInteger timeStamp = [[NSDate date] timeIntervalSince1970];
        NSData *timeStampData = [NSData packInt32:(int32_t) timeStamp flip:YES];
//        timeStampData = [NSData dataWithHexString:@"5BE14AFB"];
        [clientHelloData appendData:timeStampData];         //time
        [clientHelloData appendData:[NSData dataWithHexString:@"000000A2010000009D001002"]]; //fix

        [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000010041"]]; //fix
        [clientHelloData appendData:_pubkey1];                                           //pubkey

        [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000020041"]]; //fix
        [clientHelloData appendData:_pubkey2];                                           //pubkey

        [clientHelloData appendData:[NSData dataWithHexString:@"00000001"]]; //fix

        _clientHelloData = [clientHelloData copy];

//        DLog(@"Client Hello", _clientHelloData);
    }

    return _clientHelloData;
}

- (NSData *)getHashPart
{
    NSData *header = [NSData dataWithHexString:@"16F10300D4"];
    return [_clientHelloData subdataWithRange:NSMakeRange([header length], 0xD4)];
}

- (NSData *)getLocal1stPrikey
{
    return _prikey1;
}

@end
