//
//  DefaultShortIp.h
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "RLMObject.h"

@interface DefaultShortIp : RLMObject

@property NSString *ip;

+ (nullable instancetype)getARandomIp;

@end

