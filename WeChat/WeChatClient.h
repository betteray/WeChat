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

@property (nonatomic, strong) NSData * sessionKey;
@property (nonatomic, strong) NSData * checkEcdhKey;
@property (nonatomic, assign) int32_t uin;

@property (nonatomic, strong) NSData *pubKey;
@property (nonatomic, strong) NSData *priKey;

@property (nonatomic, copy) NSString *shortLinkUrl;

+ (instancetype)sharedClient;

- (void)start;
- (void)restartUsingIpAddress:(NSString *)IpAddress;

- (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock;

+ (void)startRequest:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock;

- (void)manualAuth:(CgiWrap *)cgiWrap
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock;

- (void)postRequest:(CgiWrap *)cgiWrap
            success:(SuccessBlock)successBlock
            failure:(FailureBlock)failureBlock;

- (void)newInitWithSyncKeyCur:(NSData *)syncKeyCur syncKeyMax:(NSData *)syncKeyMax;
@end

NS_ASSUME_NONNULL_END
