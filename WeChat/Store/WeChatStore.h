//
//  ClientCheckData.h
//  WeChat
//
//  Created by ysh on 2018/12/26.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface WeChatStore : RLMObject

@property (nonatomic, strong) NSData *sessionKey;
@property (nonatomic, strong) NSData *cookie;

@property (nonatomic, assign) int32_t uin;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, strong) NSData *clientCheckData;  //used for ios login.

//mmtls for short link
@property (nonatomic, strong) NSData *pskData;
@property (nonatomic, strong) NSData *resumptionSecret;

@end

NS_ASSUME_NONNULL_END
