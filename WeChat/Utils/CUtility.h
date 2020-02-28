//
//  CUtility.h
//  WeChat
//
//  Created by ysh on 2019/1/12.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CUtility : NSObject

+ (uint32_t)numberVersionOf:(NSString *)stringVersion;
+ (NSInteger)GetTimeStamp;

@end

NS_ASSUME_NONNULL_END
