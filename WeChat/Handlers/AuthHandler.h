//
//  AuthHandler.h
//  WeChat
//
//  Created by ray on 2019/12/21.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LOGIN_TYPE) {
    LOGIN_TYPE_MANUALAUTH,
    LOGIN_TYPE_AUTOAUTH
};

@interface AuthHandler : NSObject

+ (void)onLoginResponse:(UnifyAuthResponse *)resp from:(nullable UIViewController *)fromController loginType:(LOGIN_TYPE) loginType;

@end

NS_ASSUME_NONNULL_END
