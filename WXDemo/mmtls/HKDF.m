//
//  HKDF.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "HKDF.h"
#include <openssl/evp.h>
#include <openssl/kdf.h>

#define OUT_LEN 90
#define HASH_SIZE 32
#define MD_FUNC EVP_sha256()
#define INFO "test"
#define INFO_LEN 4

#define NID_hkdf                1036
# define EVP_PKEY_HKDF   NID_hkdf

@implementation HKDF

int tls13_hkdf_expand(const unsigned char *secret1)
{
    unsigned char secret[HASH_SIZE]={0};
    const EVP_MD *md = MD_FUNC;
    EVP_PKEY_CTX *pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_HKDF, NULL);
    
    unsigned char out[OUT_LEN];
    size_t outlen = OUT_LEN, i, ret;
    
    ret = EVP_PKEY_derive_init(pctx) <= 0
    || EVP_PKEY_CTX_hkdf_mode(pctx, EVP_PKEY_HKDEF_MODE_EXTRACT_AND_EXPAND) <= 0
    || EVP_PKEY_CTX_set_hkdf_md(pctx, md) <= 0
    || EVP_PKEY_CTX_set1_hkdf_key(pctx, secret, HASH_SIZE) <= 0
    || EVP_PKEY_CTX_add1_hkdf_info(pctx, INFO, INFO_LEN) <= 0
    || EVP_PKEY_derive(pctx, out, &outlen) <= 0;
    
    EVP_PKEY_CTX_free(pctx);
    if (ret == 0)
    {
        printf("HKDF result:%d\n",outlen);
        for(i=0;i<outlen;i++)
            printf("%02X", out[i]);
        printf("\n");
    }
    
    return 0;
}

@end
