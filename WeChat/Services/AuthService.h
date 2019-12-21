//
//  AuthService.h
//  WeChat
//
//  Created by ray on 2019/12/21.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthService : NSObject

+ (void)autoAuthWithRootViewController:(UINavigationController *)rootViewController;
+ (void)manualAuthWithViewController:(UIViewController *)viewController userName:(NSString *)userName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
