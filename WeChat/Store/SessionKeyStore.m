//
//  SessionKeyStore.m
//  WeChat
//
//  Created by ysh on 2019/1/2.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SessionKeyStore.h"

NSString *const SessionKeyStoreID = @"SessionKeyStoreID";

@implementation SessionKeyStore

+ (NSString *)primaryKey {
    return @"ID";
}

@end
