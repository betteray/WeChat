//
//  KeyPair.m
//  WXDemo
//
//  Created by ray on 2018/11/10.
//  Copyright © 2018 ray. All rights reserved.
//

#import "KeyPair.h"

@interface KeyPair ()

@property (nonatomic, strong) NSData *readKEY;
@property (nonatomic, strong) NSData *readIV;

@property (nonatomic, strong) NSData *writeKEY;
@property (nonatomic, strong) NSData *writeIV;

@end

@implementation KeyPair

- (instancetype)initWithData:(NSData *)keyPairData
{
    self = [super init];
    if (self)
    {
        _writeKEY = [keyPairData subdataWithRange:NSMakeRange(0, 0x10)];
        _readKEY = [keyPairData subdataWithRange:NSMakeRange(0x10, 0x10)];

        DLog(@"write KEY", _writeKEY);
        DLog(@"read KEY", _readKEY);

        _writeIV = [keyPairData subdataWithRange:NSMakeRange(0x20, 0xc)];
        _readIV = [keyPairData subdataWithRange:NSMakeRange(0x2c, 0xc)];

        DLog(@"write IV", _writeIV);
        DLog(@"read IV", _readIV);
    }

    return self;
}

@end
