//
//  WCSafeSDK.h
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCSafeSDK : NSObject

+ (NSData *)get003FromLocalServer:(NSString *)xml;

+ (void)reportClientCheckWithContext:(uint64_t)context basic:(BOOL)basic;

//&lt;LoginByID&gt
+ (NSData *)getExtSpamInfoWithContent:(NSString *)content
                              context:(NSString *)context;

+ (void)decodeNDM;

@end

NS_ASSUME_NONNULL_END
