//
//  SHA256.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WXSHA256.h"
#include <openssl/sha.h>

@implementation WXSHA256

+ (NSData *)wx_sha256:(char *)buf {
    SHA256_CTX ctx;
    u_int8_t results[SHA256_DIGEST_LENGTH];
    int n;
    
    n = (int)strlen(buf);
    
    SHA256_Init(&ctx);
    SHA256_Update(&ctx, (u_int8_t *)buf, n);
    SHA256_Final(results, &ctx);
    
    return [NSData dataWithBytes:results length:SHA256_DIGEST_LENGTH];
}

@end
