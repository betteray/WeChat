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

- (BOOL)saveClientCheckData:(NSData *)clientCheckData;
- (NSData *)getClientCheckData;

@end

NS_ASSUME_NONNULL_END
