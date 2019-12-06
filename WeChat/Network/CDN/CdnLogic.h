//
//  CdnLogic.h
//  WeChat
//
//  Created by ray on 2019/11/29.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessBlock)(id _Nullable response);
typedef void (^FailureBlock)(NSError *error);

@interface CdnLogic : NSObject

- (void)startC2CUpload:(NSString *)picPath
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
