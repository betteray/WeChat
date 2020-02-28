//
//  SpamInfoGenerator-Proto.h
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpamInfoGenerator_Proto : NSObject

+ (NSData *)genST:(int)a;
+ (NSData *)genBasicST;
+ (NSData *)genWCSTFWithAccount:(NSString *)account;
+ (NSData *)genWCSTEWithContext:(NSString *)context;

@end

NS_ASSUME_NONNULL_END
