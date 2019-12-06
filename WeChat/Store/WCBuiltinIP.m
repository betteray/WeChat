//
//  LongBuiltinIP.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WCBuiltinIP.h"

@implementation WCBuiltinIP

+ (NSString *)primaryKey
{
    return @"ip";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"type": @0, @"port": @0};
}

+ (nullable instancetype)getARandomLongBuiltinIP {
    RLMResults *ips = [WCBuiltinIP objectsWhere:@"isLongIP = true"];
    if ([ips count]) {
        NSInteger randomIndex = arc4random() % [ips count];
        return [ips objectAtIndex:randomIndex];
    } else {
        return nil;
    }
}


+ (nullable instancetype)getARandomShortBuiltinIP {
    RLMResults *ips = [WCBuiltinIP objectsWhere:@"isLongIP = false"];
    if ([ips count]) {
        NSInteger randomIndex = arc4random() % [ips count];
        return [ips objectAtIndex:randomIndex];
    } else {
        return nil;
    }
}

@end
