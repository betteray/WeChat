//
//  AutoAuthKeyStore.m
//  WeChat
//
//  Created by ray on 2018/12/29.
//  Copyright © 2018 ray. All rights reserved.
//

#import "AutoAuthKeyStore.h"

NSString *const AutoAuthKeyStoreID = @"AutoAuthKeyStoreID";

@implementation AutoAuthKeyStore

+ (NSString *)primaryKey {
    return @"ID";
}

@end
