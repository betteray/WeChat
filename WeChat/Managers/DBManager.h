//
//  DBManager.h
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountInfo.h"
#import "Cookie.h"
#import "SessionKeyStore.h"
#import "SyncKeyStore.h"
#import "WCBuiltinIP.h"
#import "AutoAuthKeyStore.h"
#import "WCContact.h"
#import "WCMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

+ (nullable AccountInfo *)accountInfo;
+ (void)saveAccountInfo:(uint32_t)uin
               userName:(NSString *)userName
               nickName:(NSString *)nickName
                  alias:(NSString *)alias;

+ (nullable Cookie *)cookie;
+ (void)clearCookie;
+ (void)saveCookie:(NSData *)cookie;

+ (nullable SessionKeyStore *)sessionKey;
+ (void)saveSessionKey:(NSData *)sessionKey;

+ (nullable SyncKeyStore *)syncKey;
+ (void)saveSyncKey:(NSData *)syncKey;
+ (void)clearSyncKey;

+ (void)saveBuiltinIP:(BuiltinIPList *)iplist;

+ (nullable AutoAuthKeyStore *)autoAuthKey;
+ (void)saveAutoAuthKey:(NSData *)autoAuthkey;
+ (void)clearAutoAuthKey;

+ (void)saveSelfAsWCContact:(NSString *)userName
                   nickName:(NSString *)nickName;
+ (void)saveWCContact:(ModContact *)modContact;

// msg
+ (void)saveMsg:(uint64_t)newMsgId
       withUser:(WCContact *)curUser
        msgText:(NSString *)msgText;

+ (void)saveWCMessage:(AddMsg *)msg;

@end

NS_ASSUME_NONNULL_END
