//
//  FPService.h
//  WeChat
//
//  Created by ray on 2020/2/25.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define DEVICE_TOKEN_PATH ([[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"wcsafesdk"] stringByAppendingPathComponent:@"deivcetoken.bin"])

@interface FPService : NSObject

+ (void)initFP;

@end

NS_ASSUME_NONNULL_END
