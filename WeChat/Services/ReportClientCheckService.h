//
//  ReportClientCheckService.h
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportClientCheckService : NSObject

+ (void)reportClientCheckWithContext:(uint64_t)context basic:(BOOL)basic;

@end

NS_ASSUME_NONNULL_END
