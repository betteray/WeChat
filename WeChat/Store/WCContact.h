//
//  WCContact.h
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface WCContact : RLMObject

@property NSString *userName;
@property NSString *nickName;
@property NSString *province;
@property NSString *city;
@property NSString *signature;
@property NSString *alias;
@property NSString *bigHeadImgUrl;
@property NSString *smallHeadImgUrl;

@end

NS_ASSUME_NONNULL_END
