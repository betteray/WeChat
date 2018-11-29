//
//  FSOpenSSL.m
//  OpenSSL-for-iOS
//
//  Created by Felix Schulze on 16.03.2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "FSOpenSSL.h"

#include <openssl/md5.h>
#include <openssl/sha.h>
#import <openssl/evp.h>

#include <openssl/opensslv.h>
#include <openssl/rsa.h>
#include <openssl/bn.h>

#include <openssl/aes.h>

#import <CommonCrypto/CommonCryptor.h>


//========================= RSA Start =========================

int rsa_public_encrypt(const unsigned char* pInput, unsigned int uiInputLen
                       , unsigned char** ppOutput, unsigned int* uiOutputLen
                       , NSData* modules, NSData* exponent)
{
    RSA* encrypt_rsa;
    int finalLen = 0;
    int i = 0;
    int ret;
    int rsa_len;
    if(pInput == NULL || uiOutputLen == NULL
       || modules == NULL || exponent == NULL
       || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;
    
    // assume the byte strings are sent over the network
    encrypt_rsa = RSA_new();
    if(encrypt_rsa == NULL) {
        return CRYPT_ERR_NO_MEMORY;
    }
    
    ret = CRYPT_OK;
    
    BIGNUM *bne, *bnn;//rsa算法中的 e和N
    
    bnn = BN_new();
    bne = BN_new();
    
    //看到网上有人用BN_hex2bn这个函数来转化的，但我用这个转化总是失败，最后选择了BN_bin2bn
    encrypt_rsa->e = BN_bin2bn([exponent bytes], (int)[exponent length], bne);
    encrypt_rsa->n = BN_bin2bn([modules bytes], (int)[modules length], bnn);
    
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

int rsa_public_decrypt(const unsigned char* pInput, unsigned int uiInputLen
                       , unsigned char** ppOutput, unsigned int* uiOutputLen
                       , const char* pPublicKeyN, const char* pPublicKeyE)
{
    RSA* decrypt_rsa;
    int i = 0;
    int ret = 0;
    int ret_size = 0;
    int iKeySize = 0;
    int iPlainSize = 0;
    unsigned char *pcPlainBuf = NULL;
    if(pInput == NULL || uiOutputLen == NULL
       || pPublicKeyN == NULL || pPublicKeyE == NULL
       || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;
    
    // assume the byte strings are sent over the network
    decrypt_rsa = RSA_new();
    if(decrypt_rsa == NULL) {
        return CRYPT_ERR_NO_MEMORY;
    }
    
    ret = CRYPT_OK;
    if(BN_hex2bn(&decrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if(BN_hex2bn(&decrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }
    
    // alloc encrypt_string
    iKeySize = RSA_size(decrypt_rsa);
    
    // decrypt
    pcPlainBuf = (unsigned char *)OPENSSL_malloc( uiInputLen );
    
    if (uiInputLen > (unsigned int)iKeySize)
    {
        int iBlockCnt = uiInputLen / iKeySize;
        int iPos = 0;
        
        for (i = 0; i < iBlockCnt; ++i)
        {
            ret_size = RSA_public_decrypt( iKeySize, pInput + i * iKeySize, pcPlainBuf + iPos, decrypt_rsa, RSA_PKCS1_PADDING );
            if (ret_size < 1)
            {
                ret =  CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
                goto END;
            }
            iPos += ret_size;
        }
        
        iPlainSize = iPos;
    }
    else
    {
        ret_size = RSA_public_decrypt( iKeySize, pInput, pcPlainBuf, decrypt_rsa, RSA_PKCS1_PADDING);
        
        if (ret_size < 1)
        {
            ret = CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
            goto END;
        }
        
        iPlainSize = ret_size;
    }
    
END:
    RSA_free(decrypt_rsa);
    
    if(CRYPT_OK != ret)
    {
        OPENSSL_free(pcPlainBuf);
    }
    else
    {
        *ppOutput = pcPlainBuf;
        *uiOutputLen = iPlainSize;
    }
    
    return ret;
}


@implementation FSOpenSSL

+ (NSData *)random128BitAESKey {
    unsigned char buf[16];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}


+ (NSString *)md5FromString:(NSString *)string {
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[MD5_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    MD5(inStrg, lngth, result);

    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++) {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

+ (NSString *)sha256FromString:(NSString *)string {
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[SHA256_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, inStrg, lngth);
    SHA256_Final(result, &sha256);

    unsigned int i;
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

+ (NSString *)base64FromString:(NSString *)string encodeWithNewlines:(BOOL)encodeWithNewlines {
    BIO *mem = BIO_new(BIO_s_mem());
    BIO *b64 = BIO_new(BIO_f_base64());

    if (!encodeWithNewlines) {
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    }
    mem = BIO_push(b64, mem);

    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = stringData.length;
    void *buffer = (void *) [stringData bytes];
    int bufferSize = (int)MIN(length, INT_MAX);

    NSUInteger count = 0;

    BOOL error = NO;

    // Encode the data
    while (!error && count < length) {
        int result = BIO_write(mem, buffer, bufferSize);
        if (result <= 0) {
            error = YES;
        }
        else {
            count += result;
            buffer = (void *) [stringData bytes] + count;
            bufferSize = (int)MIN((length - count), INT_MAX);
        }
    }

    int flush_result = BIO_flush(mem);
    if (flush_result != 1) {
        return nil;
    }

    char *base64Pointer;
    NSUInteger base64Length = (NSUInteger) BIO_get_mem_data(mem, &base64Pointer);

    NSData *base64data = [NSData dataWithBytesNoCopy:base64Pointer length:base64Length freeWhenDone:NO];
    NSString *base64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];

    BIO_free_all(mem);
    return base64String;
}

+ (NSData *)RSAEncryptData:(NSData *)data modulus:(NSData *)modules exponent:(NSData *)exponent
{
    unsigned char * output;
    unsigned int outputLen;
    int ret = rsa_public_encrypt([data bytes], (unsigned int)[data length], &output, &outputLen, modules, exponent);
    if (ret == CRYPT_OK) {
        return [NSData dataWithBytes:output length:outputLen];
    }
    
    return nil;
}


size_t const kKeySize = kCCKeySizeAES128;

NSData * cipherOperation(NSData *contentData, NSData *keyData, CCOperation operation) {
    NSUInteger dataLength = contentData.length;
    
    void const *initVectorBytes = keyData.bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;
    
    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyBytes,
                                          kKeySize,
                                          initVectorBytes,
                                          contentBytes,
                                          dataLength,
                                          operationBytes,
                                          operationSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

+ (NSData *) aesEncryptData:(NSData *)contentData key:(NSData *)keyData {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCEncrypt);
}

+ (NSData *) aesDecryptData:(NSData *)contentData key:( NSData *)keyData {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCDecrypt);
}

@end
