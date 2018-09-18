//
//  MarsOpenSSL.h
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarsOpenSSL : NSObject

+ (NSData *)RSA_PUB_EncryptData:(NSData *)data modulus:(NSString *)modules exponent:(NSString *)exponent;

@end
