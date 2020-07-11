//
//  EnvBits.h
//  WeChat
//
//  Created by ray on 2020/6/19.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnvBits : NSObject

+ (int)GetEnvBits;
+ (BOOL)GetEnvBits2:(int)guess result:(int)res;

@end

NS_ASSUME_NONNULL_END
