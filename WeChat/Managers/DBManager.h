//
//  DBManager.h
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

+ (instancetype)sharedManager;
//- (BOOL)saveProfile:(ManualAuthResponse_AccountInfo *)accountInfo;
//
- (BOOL)saveClientCheckData:(NSData *)clientCheckData;
- (NSData *)getClientCheckData;
//
//- (BOOL)saveSessionKey:(NSData *)sessionKey;
//- (NSData *)getSessionKey;
//
- (BOOL)saveShortIpList:(NSArray *)ipList;
- (NSArray *)getShortIpList;

- (BOOL)saveLongIpList:(NSArray *)ipList;
- (NSArray *)getLongIpList;
//
//- (BOOL)saveCookie:(NSData *)cookie;
//- (NSData *)getCookie;


@end

NS_ASSUME_NONNULL_END
