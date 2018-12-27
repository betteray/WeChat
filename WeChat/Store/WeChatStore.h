//
//  ClientCheckData.h
//  WeChat
//
//  Created by ysh on 2018/12/26.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPDATE_STORE(key, value)                          \
    do                                                    \
    {                                                     \
        [[RLMRealm defaultRealm] beginWriteTransaction];  \
        [WeChatStore getStore].key = value;               \
        [[RLMRealm defaultRealm] commitWriteTransaction]; \
    } while (0);

extern NSString *const StoreID;

@interface WeChatStore : RLMObject

@property NSInteger id;
@property NSData *sessionKey;
@property NSData *cookie;

@property int32_t uin;
@property NSString *alias;
@property NSString *userName;
@property NSString *nickName;

@property NSData *clientCheckData; //used for ios login.

//mmtls for short link
@property NSData *pskData;
@property NSData *resumptionSecret;

+ (WeChatStore *)getStore;

@end
