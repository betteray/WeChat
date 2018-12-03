//
//  WXUserDefault.h
//  WXDemo
//
//  Created by ray on 2018/11/29.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXUserDefault : NSObject

+ (void)saveWXID:(NSString *)wxid;
+ (NSString *)getWXID;

+ (void)saveUIN:(NSInteger)uin;
+ (NSInteger)getUIN;

+ (void)saveNikeName:(NSString *)nikename;
+ (NSString *)getNikeName;

+ (void)saveAlias:(NSString *)alias;
+ (NSString *)getAlias;

+ (void)saveClientCheckData:(NSData *)clientCheckData;
+ (NSData *)getClientCheckData;

@end
