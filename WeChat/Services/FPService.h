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

#define DEVICE_CONFIG_PATH ([[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"wcsafesdk"] stringByAppendingPathComponent:@"config.bin"])
#define DEVICE_DATA_PATH ([[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"wcsafesdk"] stringByAppendingPathComponent:@"data.bin"])

@interface FPService : NSObject

+ (void)initFP;
+ (void)fpfresh;

@end

NS_ASSUME_NONNULL_END
