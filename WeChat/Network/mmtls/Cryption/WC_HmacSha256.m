//
//  WX_HmacSha256.m
//  WXDemo
//
//  Created by ray on 2018/11/11.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WC_HmacSha256.h"
#include <openssl/evp.h>
#include <openssl/hmac.h>

@implementation WC_HmacSha256

+ (NSData *)HmacSha256WithKey:(NSData *)key data:(NSData *)data
{
    NSParameterAssert(key);
    NSParameterAssert(data);

    unsigned char buf[1024];
    unsigned int resultlen = 0;
    
    HMAC(EVP_sha256(), [key bytes], (int)[key length], [data bytes], (int)[data length], buf, &resultlen);
    
    return [NSData dataWithBytes:buf length:resultlen];
}

@end
