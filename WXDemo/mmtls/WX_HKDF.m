//
//  HKDF.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WX_HKDF.h"
#include <openssl/evp.h>
#include <openssl/kdf.h>
#include <openssl/hmac.h>

@implementation WX_HKDF

+ (void) OpenSSL_HKDF
{
//    unsigned char secret[HASH_SIZE]={0x75, 0x2f, 0x71, 0xeb, 0x03, 0x17, 0x57, 0x32, 0xb7, 0x51, 0x9d, 0x84, 0xa9, 0x3e, 0xe8, 0x16, 0x00, 0x36, 0x23, 0xc0, 0xcc, 0x0d, 0xc7, 0xb0, 0x4a, 0x85, 0x67, 0x23, 0xca, 0xf3, 0x62, 0x39};

//    unsigned char info[INFO_LEN] = {0x50, 0x53, 0x4b, 0x5f, 0x41, 0x43, 0x43, 0x45, 0x53, 0x53, 0x90, 0xc7, 0x16, 0x0b, 0x3a, 0xea, 0x10, 0x6a, 0x50, 0xaa, 0xfe, 0xf9, 0x38, 0x33, 0xfd, 0xac, 0xda, 0xf5, 0xa6, 0x5a, 0x5e, 0x4e, 0x0d, 0x66, 0xdf, 0xf6, 0x15, 0x98, 0xec, 0x46, 0x21, 0x2d};
}

+ (void) HKDF_Expand_Prk:(NSData *)prk Info:(NSData *)info outOkm:(NSData **)outOkm {
    unsigned char buf[56];
    [self HKDF_Expand:[prk bytes] :[prk length] :[info bytes] :[info length] :buf :56];
    *outOkm = [NSData  dataWithBytes:buf length:56];
}

+ (void) HKDF_Expand_Prk2:(NSData *)prk Info:(NSData *)info outOkm:(NSData **)outOkm {
    unsigned char buf[0x20];
    [self HKDF_Expand:[prk bytes] :[prk length] :[info bytes] :[info length] :buf :0x20];
    *outOkm = [NSData  dataWithBytes:buf length:0x20];
}

+ (void) HKDF_Expand_Prk3:(NSData *)prk Info:(NSData *)info outOkm:(NSData **)outOkm {
    unsigned char buf[28];
    [self HKDF_Expand:[prk bytes] :[prk length] :[info bytes] :[info length] :buf :28];
    *outOkm = [NSData  dataWithBytes:buf length:28];
}


+ (unsigned char *) HKDF_Expand
:(const unsigned char *)prk :(size_t) prk_len
:(const unsigned char *)info :(size_t) info_len
:(unsigned char *)okm :(size_t)okm_len
{
    const EVP_MD * evp_md = EVP_sha256();
    HMAC_CTX hmac;
    unsigned char *ret = NULL;
    
    unsigned int i;
    
    unsigned char prev[EVP_MAX_MD_SIZE];
    
    size_t done_len = 0, dig_len = EVP_MD_size(evp_md);
    
    size_t n = okm_len / dig_len;
    if (okm_len % dig_len)
        n++;
    
    if (n > 255 || okm == NULL)
        return NULL;
    
    HMAC_CTX_init(&hmac);
    
    if (!HMAC_Init_ex(&hmac, prk, (int) prk_len, evp_md, NULL))
        goto err;
    
    for (i = 1; i <= n; i++) {
        size_t copy_len;
        const unsigned char ctr = i;
        
        if (i > 1) {
            if (!HMAC_Init_ex(&hmac, NULL, 0, NULL, NULL))
                goto err;
            
            if (!HMAC_Update(&hmac, prev, dig_len))
                goto err;
        }
        
        if (!HMAC_Update(&hmac, info, info_len))
            goto err;
        
        if (!HMAC_Update(&hmac, &ctr, 1))
            goto err;
        
        if (!HMAC_Final(&hmac, prev, NULL))
            goto err;
        
        copy_len = (done_len + dig_len > okm_len) ?
        okm_len - done_len :
        dig_len;
        
        memcpy(okm + done_len, prev, copy_len);
        
        done_len += copy_len;
    }
    ret = okm;
    
err:
    OPENSSL_cleanse(prev, sizeof(prev));
    HMAC_CTX_cleanup(&hmac);
    return ret;
}

@end
