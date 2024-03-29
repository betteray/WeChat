//
//  WeChatClient.h
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GPBMessage, CgiWrap;

typedef void (^SuccessBlock)(id _Nullable response);

typedef void (^FailureBlock)(NSError *error);

@interface WeChatClient : NSObject

@property(nonatomic, strong) NSData *checkEcdhKey;
@property(nonatomic, assign) int32_t uin;

@property(nonatomic, strong) NSData *sessionKey;
@property(nonatomic, strong) NSData *cookie;

@property(nonatomic, strong) NSData *sync_key_cur;
@property(nonatomic, strong) NSData *sync_key_max;

@property(nonatomic, strong, readonly) NSData *pskData;
@property(nonatomic, strong, readonly) NSData *resumptionSecret;

@property(nonatomic, strong) NSData *priKeyData;
@property(nonatomic, strong) NSData *pubKeyData;

+ (instancetype)sharedClient;

- (void)start;
- (void)restart;
- (void)syncDone;

- (void)registerWeChat:(CgiWrap *)cgiWrap
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock;

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock;

+ (void)postRequest:(CgiWrap *)cgiWrap
            success:(SuccessBlock)successBlock
            failure:(FailureBlock)failureBlock;

+ (void)secAuth:(CgiWrap *)cgiWrap
                     success:(SuccessBlock)successBlock
                     failure:(FailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
