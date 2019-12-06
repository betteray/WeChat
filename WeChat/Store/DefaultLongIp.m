//
//  DefaultLongIp.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DefaultLongIp.h"

@implementation DefaultLongIp

+ (NSString *)primaryKey
{
    return @"ip";
}

+ (nullable instancetype)getARandomIp
{
    RLMResults *ips = [DefaultLongIp allObjects];
    if ([ips count]) {
        NSInteger randomIndex = arc4random() % [ips count];
        return [ips objectAtIndex:randomIndex];
    } else {
        return nil;
    }
}

@end
