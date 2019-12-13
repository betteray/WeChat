//
//  CdnTask.h
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessBlock)(id _Nullable response);
typedef void (^FailureBlock)(NSError *error);

@interface CdnSnsUploadTask : NSObject

- (instancetype)initWithSeq:(NSUInteger)seq;

- (void)startC2CUpload:(NSString *)picPath
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock;

- (NSDictionary *)parseResponseToDic:(NSData *)cdnPacketData;

@end

NS_ASSUME_NONNULL_END
