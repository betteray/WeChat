//
//  SpamInfoGenerator-Proto.h
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ClientSpamInfoType) {
    ClientSpamInfoType_Login,
    ClientSpamInfoType_Report
};

@interface SpamInfoGenerator_Proto : NSObject

+ (NSData *)getClientSpamInfoType:(ClientSpamInfoType)clientSpamInfoType;

+ (NSData *)genWCSTFWithAccount:(NSString *)account;
+ (NSData *)genWCSTEWithContext:(NSString *)context;

@end

NS_ASSUME_NONNULL_END
