//
//  SnsPostService.h
//  WeChat
//
//  Created by ray on 2019/12/27.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SnsPostService : NSObject

+ (void)startSendSNSPost:(NSArray *)cdnResponse;

@end

NS_ASSUME_NONNULL_END
