//
//  Business.h
//  WeChat
//
//  Created by ysh on 2019/7/10.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Business : NSObject

+ (NSData *)identifyReq2bufWithSyncKey:(NSData *)syncKey
                                   uin:(int)uin;

+ (void)newInitWithSyncKeyCur:(NSData *)syncKeyCur syncKeyMax:(NSData *)syncKeyMax;

+ (void)newSync;

@end

NS_ASSUME_NONNULL_END
