//
//  AuthHandler.h
//  WeChat
//
//  Created by ray on 2019/12/21.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthHandler : NSObject

+ (void)onLoginResponse:(UnifyAuthResponse *)resp from:(nullable UIViewController *)fromController;

@end

NS_ASSUME_NONNULL_END
