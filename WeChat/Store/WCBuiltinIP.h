//
//  LongBuiltinIP.h
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface WCBuiltinIP : RLMObject

@property BOOL isLongIP;

@property NSString *ip;
@property NSString *domain;
@property int32_t type;
@property int32_t port;

@end

NS_ASSUME_NONNULL_END
