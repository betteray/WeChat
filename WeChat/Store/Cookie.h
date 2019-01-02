//
//  Cookie.h
//  WeChat
//
//  Created by ysh on 2019/1/2.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const CookieID;

@interface Cookie : RLMObject

@property NSString *ID;

@property NSData *data;

@end

NS_ASSUME_NONNULL_END
