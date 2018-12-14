//
//  DBManager.h
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+ (instancetype)sharedManager;
- (BOOL)saveProfile:(ManualAuthResponse_AccountInfo *)accountInfo;

- (BOOL)saveClientCheckData:(NSData *)clientCheckData;
- (NSData *)getClientCheckData;

@end
