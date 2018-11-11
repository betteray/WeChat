//
//  WX_HmacSha256.m
//  WXDemo
//
//  Created by ray on 2018/11/11.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WX_HmacSha256.h"
#include <openssl/evp.h>
#include <openssl/hmac.h>

@implementation WX_HmacSha256

+ (unsigned char*) HmacSha256WithKey:(NSData *)key data:(NSData *)data result:(NSData **)result
{
    NSParameterAssert(key);
    NSParameterAssert(data);

    unsigned char buf[1024];
    unsigned int resultlen = 0;
    
    unsigned char* r = HMAC(EVP_sha256(), [key bytes], (int)[key length], [data bytes], (int)[data length], buf, &resultlen);
    *result = [NSData dataWithBytes:buf length:resultlen];
    
    return r;
}

@end
