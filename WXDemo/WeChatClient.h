//
//  WeChatClient.h
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPBMessage, CgiWrap;

typedef void (^SuccessBlock)(GPBMessage *_Nullable response);
typedef void (^FailureBlock)(NSError *error);

@interface WeChatClient : NSObject

+ (instancetype)sharedClient;
- (void)start;

- (void)startRequest:(CgiWrap *)request
             success:(SuccessBlock)successBlock
             failure:(FailureBlock)failureBlock;

@property (nonatomic, strong) NSData *aesKey;

@end
