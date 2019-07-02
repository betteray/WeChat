//
//  AesGcm.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WC_AesGcm128 : NSObject

+ (NSData *)aes128gcmEncrypt:(NSData *)plaintext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;

+ (NSData *)aes192gcmEncrypt:(NSData *)plaintext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;

+ (NSData *)aes128gcmDecrypt:(NSData *)ciphertext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;

+ (NSData *)aes192gcmDecrypt:(NSData *)ciphertext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;

@end
