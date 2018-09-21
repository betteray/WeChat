//
//  NSData+GenRandomData.m
//  WXDemo
//
//  Created by ray on 2018/9/21.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+GenRandomData.h"

@implementation NSData (GenRandomData)

+ (instancetype)GenRandomDataWithSize: (int) len;
{
    NSMutableData* randomData = [NSMutableData dataWithCapacity:len];
    for( unsigned int i = 0 ; i < len/4 ; ++i )
    {
        u_int32_t randomBits = arc4random();
        [randomData appendBytes:(void*)&randomBits length:4];
    }
    return randomData;
}

@end
