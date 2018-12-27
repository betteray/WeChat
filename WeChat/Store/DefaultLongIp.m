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

+ (NSString *)getARandomIp
{
    RLMResults *ips = [DefaultLongIp allObjects];
    NSInteger randomIndex = arc4random() % [ips count];
    return [ips objectAtIndex:randomIndex];
}

@end
