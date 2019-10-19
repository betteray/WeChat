//
//  RiskScanBufUtil.h
//  WeChat
//
//  Created by ray on 2019/10/18.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RiskScanBufUtil : NSObject

+ (NSData *)getKey;

+ (NSData *)encrypt:(NSData *)data key:(NSData *)key;
+ (NSData *)decrypt:(NSData *)ciphertext key:(NSData *)key;

@end

NS_ASSUME_NONNULL_END
