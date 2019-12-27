//
//  PersonalInfoService.h
//  WeChat
//
//  Created by ray on 2019/10/14.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalInfoService : NSObject

+ (void)getprofileSuccess:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
