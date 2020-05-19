//
//  MessageHooks.h
//  WeChat
//
//  Created by ray on 2020/5/19.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHooks : NSObject

+ (void)handleMsg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
