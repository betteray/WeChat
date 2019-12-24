//
//  OplogService.h
//  WeChat
//
//  Created by ray on 2019/12/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OplogService : NSObject

+ (void)oplogRequestWithCmdId:(uint32_t)cmdId message:(GPBMessage *)message;

@end

NS_ASSUME_NONNULL_END
