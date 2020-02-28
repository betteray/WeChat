//
//  SpamInfoGenerator-XML.h
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpamInfoGenerator_XML : NSObject

+ (NSString *)genST:(int)a;
+ (NSString *)genBasicST;
+ (NSString *)genWCSTFWithAccount:(NSString *)account;
+ (NSString *)genWCSTEWithContext:(NSString *)context;

@end

NS_ASSUME_NONNULL_END
