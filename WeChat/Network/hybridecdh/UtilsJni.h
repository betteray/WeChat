//
//  UtilsJni.h
//  WeChat
//
//  Created by ysh on 2019/7/1.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilsJni : NSObject

- (NSData *)HybridEcdhEncrypt:(NSData *)plainData;

- (NSData *)HybridEcdhDecrypt:(NSData *)encryptedData;

@end

NS_ASSUME_NONNULL_END
