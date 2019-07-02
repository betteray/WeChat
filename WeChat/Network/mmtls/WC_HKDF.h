//
//  HKDF.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WC_HKDF : NSObject

+ (NSData *)HKDF_Expand:(NSData *)prk Info:(NSData *)info;
+ (NSData *)HKDF_Expand_Prk2:(NSData *)prk Info:(NSData *)info;
+ (void)HKDF_Expand_Prk3:(NSData *)prk Info:(NSData *)info outOkm:(NSData **)outOkm;

+ (int) HKDF_salt:(const unsigned char *)salt salt_len:(size_t) salt_len
              ikm:(const unsigned char *)ikm ikm_len:(size_t)ikm_len
             info:(const unsigned char *)info info_len:(size_t) info_len
              okm:(unsigned char *)okm okm_len:(size_t) okm_len;

@end
