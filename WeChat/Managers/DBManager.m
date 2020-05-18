//
//  DBManager.m
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

+ (nullable AccountInfo *)accountInfo {
    NSPredicate *accountInfoPre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
    return [[AccountInfo objectsWithPredicate:accountInfoPre] firstObject];
}

+ (void)saveAccountInfo:(uint32_t)uin
               userName:(NSString *)userName
               nickName:(NSString *)nickName
                  alias:(NSString *)alias {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [AccountInfo createOrUpdateInDefaultRealmWithValue:@[AccountInfoID, @(uin), userName, nickName, alias]];
    [realm commitWriteTransaction];
}

+ (nullable Cookie *)cookie {
    NSPredicate *cookiePre = [NSPredicate predicateWithFormat:@"ID = %@", CookieID];
    return [[Cookie objectsWithPredicate:cookiePre] firstObject];
}

+ (void)clearCookie {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    Cookie *cookie = [DBManager cookie];
    if (cookie) {
        [realm deleteObject:cookie];
    }
    [realm commitWriteTransaction];
}

+ (void)saveCookie:(NSData *)cookie {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [Cookie createOrUpdateInDefaultRealmWithValue:@[CookieID, cookie]];
    [realm commitWriteTransaction];
}

+ (nullable SessionKeyStore *)sessionKey {
    NSPredicate *sessionKeyStorePre = [NSPredicate predicateWithFormat:@"ID = %@", SessionKeyStoreID];
    return [[SessionKeyStore objectsWithPredicate:sessionKeyStorePre] firstObject];
}

+ (void)saveSessionKey:(NSData *)sessionKey {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [SessionKeyStore createOrUpdateInDefaultRealmWithValue:@[SessionKeyStoreID, sessionKey]];
    [realm commitWriteTransaction];
}

+ (nullable SyncKeyStore *)syncKey {
    NSPredicate *syncKeyStorePre = [NSPredicate predicateWithFormat:@"ID = %@", SyncKeyStoreID];
    return [[SyncKeyStore objectsWithPredicate:syncKeyStorePre] firstObject];
}

+ (void)saveSyncKey:(NSData *)syncKey {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [SyncKeyStore createOrUpdateInDefaultRealmWithValue:@[SyncKeyStoreID, syncKey]];
    [realm commitWriteTransaction];
}

+ (void)clearSyncKey {
    SyncKeyStore *store = [self syncKey];
    if (store) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:store];
        [realm commitWriteTransaction];
    }
}

+ (void)saveBuiltinIP:(BuiltinIPList *)iplist {
    // 存数据到数据库。
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (BuiltinIP *longBuiltinIp in iplist.longConnectIplistArray) {
        NSString *domain = [[NSString alloc] initWithData:longBuiltinIp.domain encoding:NSUTF8StringEncoding];
        NSString *ipString = [[NSString alloc] initWithData:longBuiltinIp.ip encoding:NSUTF8StringEncoding];
        WCBuiltinIP *ip = [[WCBuiltinIP alloc] initWithValue:@{@"isLongIP": @YES,
                @"type": @(longBuiltinIp.type),
                @"port": @(longBuiltinIp.port),
                @"ip": [ipString stringByReplacingOccurrencesOfString:@"\0" withString:@""],
                @"domain": domain}];
        [realm addOrUpdateObject:ip];

    };

    for (BuiltinIP *longBuiltinIp in iplist.shortConnectIplistArray) {
        NSString *domain = [[NSString alloc] initWithData:longBuiltinIp.domain encoding:NSUTF8StringEncoding];
        NSString *ipString = [[NSString alloc] initWithData:longBuiltinIp.ip encoding:NSUTF8StringEncoding];
        WCBuiltinIP *ip = [[WCBuiltinIP alloc] initWithValue:@{@"isLongIP": @NO,
                @"type": @(longBuiltinIp.type),
                @"port": @(longBuiltinIp.port),
                @"ip": [ipString stringByReplacingOccurrencesOfString:@"\0" withString:@""],
                @"domain": domain}];
        [realm addOrUpdateObject:ip];
    };
    
    [realm commitWriteTransaction];
}

+ (nullable AutoAuthKeyStore *)autoAuthKey {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AutoAuthKeyStoreID];
    return [[AutoAuthKeyStore objectsWithPredicate:pre] firstObject];
}

+ (void)clearAutoAuthKey {
    AutoAuthKeyStore *store = [self autoAuthKey];
    if (store) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:store];
        [realm commitWriteTransaction];
    }
}

+ (void)saveAutoAuthKey:(NSData *)autoAuthkey {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [AutoAuthKeyStore createOrUpdateInDefaultRealmWithValue:@[AutoAuthKeyStoreID, autoAuthkey]];
    [realm commitWriteTransaction];
}

+ (void)saveSelfAsWCContact:(NSString *)userName
                   nickName:(NSString *)nickName {
    WCContact *slf = [[WCContact objectsWhere:@"userName = %@", userName] firstObject];
    if (!slf) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
            [WCContact createOrUpdateInDefaultRealmWithValue:@[userName,
                    nickName,
                    @"",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""]];
        
        [realm commitWriteTransaction];
    }
}

+ (void)saveWCContact:(ModContact *)modContact {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [WCContact createOrUpdateInDefaultRealmWithValue:@[modContact.userName.string,
                                                       modContact.nickName.string,
                                                       modContact.province,
                                                       modContact.city,
                                                       modContact.signature,
                                                       modContact.alias,
                                                       modContact.bigHeadImgURL,
                                                       modContact.smallHeadImgURL]];
    [realm commitWriteTransaction];
}

+ (void)saveMsg:(uint64_t)newMsgId
       withUser:(WCContact *)curUser
        msgText:(NSString *)msgText {
    AccountInfo *info = [DBManager accountInfo];
    WCContact *slf = [[WCContact objectsWhere:@"userName = %@", info.userName] firstObject];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [WCMessage createOrUpdateInDefaultRealmWithValue:@[@(newMsgId),
                                                       slf,
                                                       curUser,
                                                       @(1),
                                                       msgText,
                                                       @((NSInteger)[[NSDate date] timeIntervalSince1970])]];
    [realm commitWriteTransaction];
}

+ (void)saveWCMessage:(AddMsg *)msg {
    WCContact *fromUser = [[WCContact objectsWhere:@"userName = %@", msg.fromUserName.string] firstObject];
    WCContact *toUser = [[WCContact objectsWhere:@"userName = %@", msg.toUserName.string] firstObject];

    if (fromUser && toUser) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [WCMessage createOrUpdateInDefaultRealmWithValue:@[@(msg.newMsgId),
                                                           fromUser,
                                                           toUser,
                                                           @(msg.msgType),
                                                           msg.content.string,
                                                           @(msg.createTime)]];
        [realm commitWriteTransaction];
    }
    else
    {
        LogError(@"Can not find contact with username: %@", msg.fromUserName.string);
        LogError(@"But the content is: %@", msg.content.string);
    }
}
@end
