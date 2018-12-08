//
//  ShortLinkKey.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkKey.h"

@interface ShortLinkKey ()

@property (nonatomic, strong) NSData *KEY;
@property (nonatomic, strong) NSData *IV;

@end

@implementation ShortLinkKey

- (instancetype)initWithData:(NSData *)keyData
{
    self = [super init];
    if (self)
    {
        _KEY = [keyData subdataWithRange:NSMakeRange(0, 0x10)];
        _IV = [keyData subdataWithRange:NSMakeRange(0x10, 0xc)];

        DLog(@"write KEY", _KEY);
        DLog(@"write IV", _IV);
    }
    return self;
}

@end
