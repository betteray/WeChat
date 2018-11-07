//
//  AesGcm.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A_esGcm : NSObject

// encrypt plaintext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec, and tag to NSData/NSMutableData
+ (BOOL) aes128gcmEncrypt:(NSData*)plaintext
               ciphertext:(NSMutableData**)ciphertext
                      aad:(NSData*)aad
                      key:(const unsigned char*)key
                     ivec:(const unsigned char*)ivec
                      tag:(unsigned char*)tag;
// decrypt ciphertext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec, and tag to NSData/NSMutableData
+ (BOOL) aes128gcmDecrypt:(NSData*)ciphertext
                plaintext:(NSMutableData**)plaintext
                      aad:(NSData*)aad
                      key:(const unsigned char *)key
                     ivec:(const unsigned char *)ivec
                      tag:(unsigned char *)tag;

@end
