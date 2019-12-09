//
//  CdnLogic.h
//  WeChat
//
//  Created by ray on 2019/11/29.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CdnLogic : NSObject

+ (instancetype)sharedInstance;

- (void)startC2CUpload:(NSArray<NSString *> *)picPaths
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
