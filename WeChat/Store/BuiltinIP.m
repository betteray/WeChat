//
//  LongBuiltinIP.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "BuiltinIP.h"

@implementation BuiltinIP

+ (NSString *)primaryKey
{
    return @"ip";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"type": @0, @"port": @0};
}

@end
