//
//  AccountInfo.h
//  WeChat
//
//  Created by ysh on 2019/1/2.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const AccountInfoID;

@interface AccountInfo : RLMObject

@property NSString *ID;

@property int32_t uin;
@property NSString *userName;
@property NSString *nickName;
@property NSString *alias;

@end

NS_ASSUME_NONNULL_END
