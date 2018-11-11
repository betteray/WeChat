//
//  AesGcm.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WX_AesGcm128 : NSObject


+ (BOOL) aes128gcmEncrypt:(NSData*)plaintext
               ciphertext:(NSMutableData**)ciphertext
                      aad:(NSData*)aad
                      key:(NSData*)key
                     ivec:(NSData*)ivec;


+ (BOOL) aes128gcmDecrypt:(NSData*)ciphertext
                plaintext:(NSData**)outPlaintext
                      aad:(NSData*)aad
                      key:(NSData*)key
                     ivec:(NSData*)ivec;

@end
