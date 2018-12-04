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
        [clientHelloData appendData:[NSData packInt32:(int32_t) timeStamp flip:NO]];         //time
        [clientHelloData appendData:[NSData dataWithHexString:@"000000A2010000009D001002"]]; //fix

        [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000010041"]]; //fix
        [clientHelloData appendData:_pubkey1];                                           //pubkey

        [clientHelloData appendData:[NSData dataWithHexString:@"00000047000000020041"]]; //fix
        [clientHelloData appendData:_pubkey2];                                           //pubkey

        [clientHelloData appendData:[NSData dataWithHexString:@"00000001"]]; //fix

        _clientHelloData = [clientHelloData copy];

        DLog(@"Client Hello", _clientHelloData);
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
