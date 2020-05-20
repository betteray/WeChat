//
//  PasswordService.h
//  WeChat
//
//  Created by ray on 2020/5/20.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasswordService : NSObject

+ (void)NewverifyPasswd:(NSString *)curPassword newPassword:(NSString *)newPassword;

@end

NS_ASSUME_NONNULL_END
