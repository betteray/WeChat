//
//  ZZEncryptService.h
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZEncryptService : NSObject

+ (NSData *)get003FromLocal:(id)protoOrXml;

+ (NSString *)getFPMd5;

+ (NSData *)get003:(id)protoOrXml;

@end

NS_ASSUME_NONNULL_END
