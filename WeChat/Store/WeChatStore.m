//
//  ClientCheckData.m
//  WeChat
//
//  Created by ysh on 2018/12/26.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WeChatStore.h"

NSString *const StoreID = @"WeChatStore";

@implementation WeChatStore

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"uin" : @0};
}

+ (WeChatStore *)getStore
{
    WeChatStore *store = nil;
    store = [[WeChatStore allObjects] firstObject];
    if (!store) {
        store = [[WeChatStore alloc] init];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:store];
        }];
    }
    
    return store;
}


@end
