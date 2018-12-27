//
//  DefaultShortIp.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DefaultShortIp.h"

@implementation DefaultShortIp

+ (NSString *)primaryKey
{
    return @"ip";
}

+ (NSString *)getARandomIp
{
    RLMResults *ips = [DefaultShortIp allObjects];
    NSInteger randomIndex = arc4random() % [ips count];
    return [ips objectAtIndex:randomIndex];
}

@end
