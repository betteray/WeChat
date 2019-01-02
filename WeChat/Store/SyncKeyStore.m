//
//  SyncKeyStore.m
//  WeChat
//
//  Created by ray on 2018/12/29.
//  Copyright © 2018 ray. All rights reserved.
//

#import "SyncKeyStore.h"

NSString *const SyncKeyStoreID = @"SyncKeyStoreID";

@implementation SyncKeyStore

+ (NSString *)primaryKey {
    return @"ID";
}

@end
