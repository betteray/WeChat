//
//  AES_EVP.h
//  WeChat
//
//  Created by ray on 2019/12/5.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AES_EVP : NSObject

+ (NSData *)AES_ECB_128_Encrypt:(NSData *)plainText key:(NSData *)key;
+ (NSData *)AES_CBC_128_Encrypt:(NSData *)plainText key:(NSData *)key;

+ (NSData *)AES_ECB_128_Decrypt:(NSData *)chiperText key:(NSData *)key;

+ (NSString *)encrypedUserName:(NSString *)plainText WithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
