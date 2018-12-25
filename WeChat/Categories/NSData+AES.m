//
//  NSData+AES.m
//  WXDemo
//
//  Created by ray on 2018/9/21.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+AES.h"
#include <openssl/aes.h>

#define AES_KEY_LEN 16
#define AES_KEY_BITSET_LEN 128

static int aes_cbc_encrypt(const unsigned char *pKey, unsigned int uiKeyLen, const unsigned char *pInput, unsigned int uiInputLen, unsigned char **ppOutput, unsigned int *pOutputLen)
{
    unsigned char keyBuf[AES_KEY_LEN] = {0};
    unsigned char iv[AES_KEY_LEN];

    AES_KEY aesKey;
    int ret;

    unsigned int uiPaddingLen;
    unsigned int uiTotalLen;
    unsigned char *pData;

    if (pKey == NULL || uiKeyLen == 0 || pInput == NULL || uiInputLen == 0 || pOutputLen == NULL || ppOutput == NULL)
        return -1;

    memcpy(keyBuf, pKey, (uiKeyLen > AES_KEY_LEN) ? AES_KEY_LEN : uiKeyLen);
    memcpy(iv, keyBuf, AES_KEY_LEN);

    ret = AES_set_encrypt_key(keyBuf, AES_KEY_BITSET_LEN, &aesKey);
    if (ret != 0)
        return -2;

    //padding
    uiPaddingLen = AES_KEY_LEN - (uiInputLen % AES_KEY_LEN);
    uiTotalLen = uiInputLen + uiPaddingLen;
    pData = malloc(uiTotalLen);
    memcpy(pData, pInput, uiInputLen);

    if (uiPaddingLen > 0)
        memset(pData + uiInputLen, uiPaddingLen, uiPaddingLen);

    *pOutputLen = uiTotalLen;
    *ppOutput = malloc(uiTotalLen);
    memset(*ppOutput, 0, uiTotalLen);

    AES_cbc_encrypt(pData, *ppOutput, uiTotalLen, &aesKey, iv, AES_ENCRYPT);

    free(pData);
    return 0;
}

static int aes_cbc_decrypt(const unsigned char *pKey, unsigned int uiKeyLen, const unsigned char *pInput, unsigned int uiInputLen, unsigned char **ppOutput, unsigned int *pOutputLen)
{

    unsigned char keyBuf[AES_KEY_LEN] = {0};
    unsigned char iv[AES_KEY_LEN];

    AES_KEY aesKey;
    int ret;
    int uiPaddingLen;

    if (pKey == NULL || uiKeyLen == 0 || pInput == NULL || uiInputLen == 0 || pOutputLen == NULL || (uiInputLen % AES_KEY_LEN) != 0 || ppOutput == NULL)
        return -1;

    memcpy(keyBuf, pKey, (uiKeyLen > AES_KEY_LEN) ? AES_KEY_LEN : uiKeyLen);
    memcpy(iv, keyBuf, AES_KEY_LEN);

    ret = AES_set_decrypt_key(keyBuf, AES_KEY_BITSET_LEN, &aesKey);
    if (ret != 0)
    {
        return -2;
    }

    *ppOutput = malloc(uiInputLen);
    memset(*ppOutput, 0, uiInputLen);

    AES_cbc_encrypt(pInput, *ppOutput, uiInputLen, &aesKey, iv, AES_DECRYPT);

    uiPaddingLen = (*ppOutput)[uiInputLen - 1];
    if (uiPaddingLen > AES_KEY_LEN || uiPaddingLen <= 0)
    {
        free(*ppOutput);
        ppOutput = NULL;
        return -3;
    }

    *pOutputLen = uiInputLen - uiPaddingLen;

    return 0;
}

@implementation NSData (AES)

- (NSData *)AES_CBC_encryptWithKey:(NSData *)aesKey
{
    const unsigned char *pKey = [aesKey bytes];
    unsigned int uiKeyLen = (unsigned int) [aesKey length];

    const unsigned char *pInput = [self bytes];
    unsigned int uiPinputLen = (unsigned int) [self length];

    unsigned char *pOutput;
    unsigned int outputLen;

    int ret = aes_cbc_encrypt(pKey, uiKeyLen, pInput, uiPinputLen, &pOutput, &outputLen);
    if (ret == 0)
    {
        return [NSData dataWithBytes:pOutput length:outputLen];
    }
    else
    {
        LogError(@"AES_CBC_encryptWithKey error: %d", ret);
        return nil;
    }
}

- (NSData *)AES_CBC_decryptWithKey:(NSData *)aesKey
{
    const unsigned char *pKey = [aesKey bytes];
    unsigned int uiKeyLen = (unsigned int) [aesKey length];

    const unsigned char *pInput = [self bytes];
    unsigned int uiPinputLen = (unsigned int) [self length];

    unsigned char *pOutput;
    unsigned int outputLen;

    int ret = aes_cbc_decrypt(pKey, uiKeyLen, pInput, uiPinputLen, &pOutput, &outputLen);
    if (ret == 0)
    {
        return [NSData dataWithBytes:pOutput length:outputLen];
    }
    else
    {
        LogError(@"AES_CBC_encryptWithKey error: %d", ret);
        return nil;
    }
}

@end
