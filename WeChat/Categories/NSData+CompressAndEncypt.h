//
//  NSData+CompressAndEncypt.h
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CompressAndEncypt)

//Send
- (NSData *)Compress_And_RSA;
- (NSData *)Compress_And_AES;
- (NSData *)AES;

- (NSData *)aesDecryptWithKey:(NSData *)key;
- (NSData *)aesDecrypt_then_decompress;

@end
