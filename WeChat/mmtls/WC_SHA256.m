//
//  SHA256.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WC_SHA256.h"
#include <openssl/sha.h>

@implementation WC_SHA256

+ (NSData *)sha256:(NSData *)data
{
    SHA256_CTX ctx;
    u_int8_t results[SHA256_DIGEST_LENGTH];
    int n;

    n = (int) [data length];

    SHA256_Init(&ctx);
    SHA256_Update(&ctx, (u_int8_t *) [data bytes], n);
    SHA256_Final(results, &ctx);

    return [NSData dataWithBytes:results length:SHA256_DIGEST_LENGTH];
}

@end
