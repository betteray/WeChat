//
//  MarsOpenSSL.m
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "MarsOpenSSL.h"
#include <openssl/rsa.h>

enum
{
    CRYPT_OK = 0,
    CRYPT_ERR_INVALID_KEY_N = 1,
    CRYPT_ERR_INVALID_KEY_E = 2,
    CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY = 3,
    CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY = 4,
    CRYPT_ERR_NO_MEMORY = 5,
    CRYPT_ERR_ENCRYPT_WITH_DES_KEY = 6,
    CRYPT_ERR_DECRYPT_WITH_DES_KEY = 7,
    CRYPT_ERR_INVALID_PARAM = 8,
    CRYPT_ERR_LOAD_RSA_PRIVATE_KEY = 9,
};

static int rsa_public_encrypt(const unsigned char* pInput, unsigned int uiInputLen
                       , unsigned char** ppOutput, unsigned int* uiOutputLen
                       , const char* pPublicKeyN, const char* pPublicKeyE)
{
    RSA* encrypt_rsa;
    int finalLen = 0;
    int i = 0;
    int ret;
    int rsa_len;
    if(pInput == NULL || uiOutputLen == NULL
       || pPublicKeyN == NULL || pPublicKeyE == NULL
       || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;
    
    // assume the byte strings are sent over the network
    encrypt_rsa = RSA_new();
    if(encrypt_rsa == NULL) {
        return CRYPT_ERR_NO_MEMORY;
    }
    
    ret = CRYPT_OK;
    if(BN_hex2bn(&encrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if(BN_hex2bn(&encrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }
    
    // alloc encrypt_string
    
    rsa_len = RSA_size(encrypt_rsa);
    if((int)uiInputLen >= rsa_len - 12) {
        int blockCnt = (uiInputLen / (rsa_len - 12)) + (((uiInputLen % (rsa_len - 12)) == 0) ? 0 : 1);
        finalLen = blockCnt * rsa_len;
        *ppOutput = (unsigned char*)calloc(finalLen, sizeof(unsigned char));
        if(*ppOutput == NULL) {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }
        
        
        for(; i < blockCnt; ++i) {
            int blockSize = rsa_len - 12;
            if(i == blockCnt - 1) blockSize = uiInputLen - i * blockSize;
            
            if(RSA_public_encrypt(blockSize, (pInput + i * (rsa_len - 12)), (*ppOutput + i * rsa_len), encrypt_rsa, RSA_PKCS1_PADDING) < 0) {
                ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
                goto END;
            }
        }
        *uiOutputLen = finalLen;
    } else {
        *ppOutput = (unsigned char*)calloc(rsa_len, sizeof(unsigned char));
        if (*ppOutput == NULL) {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }
        
        // encrypt (return the size of the encrypted data)
        // note that if RSA_PKCS1_OAEP_PADDING is used,
        // flen must be < RSA_size - 41
        if(RSA_public_encrypt(uiInputLen,
                              pInput, *ppOutput, encrypt_rsa, RSA_PKCS1_PADDING) < 0) {
            ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
            goto END;
        }
        *uiOutputLen = rsa_len;
    }
    
END:
    if(CRYPT_OK != ret) {
        if(*ppOutput != NULL) {
            free(*ppOutput);
            ppOutput = NULL;
        }
    }
    RSA_free(encrypt_rsa);
    return ret;
}

@implementation MarsOpenSSL

+ (NSData *)RSA_PUB_EncryptData:(NSData *)data modulus:(NSString *)modules exponent:(NSString *)exponent
{
    unsigned char * output;
    unsigned int outputLen;
    int ret = rsa_public_encrypt([data bytes], (unsigned int)[data length], &output, &outputLen, [modules UTF8String], [exponent UTF8String]);
    if (ret == CRYPT_OK) {
        return [NSData dataWithBytes:output length:outputLen];
    }
    
    return nil;
}

@end
