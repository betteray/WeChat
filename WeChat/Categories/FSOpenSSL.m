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
#include <openssl/pem.h>
#include <openssl/err.h>

#import <CommonCrypto/CommonCryptor.h>

//========================= RSA Start =========================

int rsa_public_encrypt(const unsigned char *pInput, unsigned int uiInputLen, unsigned char **ppOutput, unsigned int *uiOutputLen, NSData *modules, NSData *exponent)
{
    RSA *encrypt_rsa;
    int finalLen = 0;
    int i = 0;
    int ret;
    int rsa_len;
    if (pInput == NULL || uiOutputLen == NULL || modules == NULL || exponent == NULL || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;

    // assume the byte strings are sent over the network
    encrypt_rsa = RSA_new();
    if (encrypt_rsa == NULL)
    {
        return CRYPT_ERR_NO_MEMORY;
    }

    ret = CRYPT_OK;

    BIGNUM *bne, *bnn; //rsa算法中的 e和N

    bnn = BN_new();
    bne = BN_new();

    //看到网上有人用BN_hex2bn这个函数来转化的，但我用这个转化总是失败，最后选择了BN_bin2bn
    encrypt_rsa->e = BN_bin2bn([exponent bytes], (int) [exponent length], bne);
    encrypt_rsa->n = BN_bin2bn([modules bytes], (int) [modules length], bnn);

    // alloc encrypt_string

    rsa_len = RSA_size(encrypt_rsa);
    if ((int) uiInputLen >= rsa_len - 12)
    {
        int blockCnt = (uiInputLen / (rsa_len - 12)) + (((uiInputLen % (rsa_len - 12)) == 0) ? 0 : 1);
        finalLen = blockCnt * rsa_len;
        *ppOutput = (unsigned char *) calloc(finalLen, sizeof(unsigned char));
        if (*ppOutput == NULL)
        {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }

        for (; i < blockCnt; ++i)
        {
            int blockSize = rsa_len - 12;
            if (i == blockCnt - 1)
                blockSize = uiInputLen - i * blockSize;

            if (RSA_public_encrypt(blockSize, (pInput + i * (rsa_len - 12)), (*ppOutput + i * rsa_len), encrypt_rsa, RSA_PKCS1_PADDING) < 0)
            {
                ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
                goto END;
            }
        }
        *uiOutputLen = finalLen;
    }
    else
    {
        *ppOutput = (unsigned char *) calloc(rsa_len, sizeof(unsigned char));
        if (*ppOutput == NULL)
        {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }

        // encrypt (return the size of the encrypted data)
        // note that if RSA_PKCS1_OAEP_PADDING is used,
        // flen must be < RSA_size - 41
        if (RSA_public_encrypt(uiInputLen,
                               pInput, *ppOutput, encrypt_rsa, RSA_PKCS1_PADDING) < 0)
        {
            ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
            goto END;
        }
        *uiOutputLen = rsa_len;
    }

END:
    if (CRYPT_OK != ret)
    {
        if (*ppOutput != NULL)
        {
            free(*ppOutput);
            ppOutput = NULL;
        }
    }
    RSA_free(encrypt_rsa);
    return ret;
}

int rsa_public_decrypt(const unsigned char *pInput, unsigned int uiInputLen, unsigned char **ppOutput, unsigned int *uiOutputLen, const char *pPublicKeyN, const char *pPublicKeyE)
{
    RSA *decrypt_rsa;
    int i = 0;
    int ret = 0;
    int ret_size = 0;
    int iKeySize = 0;
    int iPlainSize = 0;
    unsigned char *pcPlainBuf = NULL;
    if (pInput == NULL || uiOutputLen == NULL || pPublicKeyN == NULL || pPublicKeyE == NULL || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;

    // assume the byte strings are sent over the network
    decrypt_rsa = RSA_new();
    if (decrypt_rsa == NULL)
    {
        return CRYPT_ERR_NO_MEMORY;
    }

    ret = CRYPT_OK;
    if (BN_hex2bn(&decrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if (BN_hex2bn(&decrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }

    // alloc encrypt_string
    iKeySize = RSA_size(decrypt_rsa);

    // decrypt
    pcPlainBuf = (unsigned char *) OPENSSL_malloc(uiInputLen);

    if (uiInputLen > (unsigned int) iKeySize)
    {
        int iBlockCnt = uiInputLen / iKeySize;
        int iPos = 0;

        for (i = 0; i < iBlockCnt; ++i)
        {
            ret_size = RSA_public_decrypt(iKeySize, pInput + i * iKeySize, pcPlainBuf + iPos, decrypt_rsa, RSA_PKCS1_PADDING);
            if (ret_size < 1)
            {
                ret = CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
                goto END;
            }
            iPos += ret_size;
        }

        iPlainSize = iPos;
    }
    else
    {
        ret_size = RSA_public_decrypt(iKeySize, pInput, pcPlainBuf, decrypt_rsa, RSA_PKCS1_PADDING);

        if (ret_size < 1)
        {
            ret = CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY;
            goto END;
        }

        iPlainSize = ret_size;
    }

END:
    RSA_free(decrypt_rsa);

    if (CRYPT_OK != ret)
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

///////

static int rsa_public_encrypt1(const unsigned char *pInput,
                               unsigned int uiInputLen,
                               unsigned char **ppOutput,
                               unsigned int *uiOutputLen,
                               const char *pPublicKeyN,
                               const char *pPublicKeyE)
{
    RSA *encrypt_rsa;
    int finalLen = 0;
    int i = 0;
    int ret;
    int rsa_len;
    if (pInput == NULL || uiOutputLen == NULL || pPublicKeyN == NULL || pPublicKeyE == NULL || uiInputLen == 0 || ppOutput == NULL)
        return CRYPT_ERR_INVALID_PARAM;

    // assume the byte strings are sent over the network
    encrypt_rsa = RSA_new();
    if (encrypt_rsa == NULL)
    {
        return CRYPT_ERR_NO_MEMORY;
    }

    ret = CRYPT_OK;
    if (BN_hex2bn(&encrypt_rsa->n, pPublicKeyN) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_N;
        goto END;
    }
    if (BN_hex2bn(&encrypt_rsa->e, pPublicKeyE) == 0)
    {
        ret = CRYPT_ERR_INVALID_KEY_E;
        goto END;
    }

    // alloc encrypt_string

    rsa_len = RSA_size(encrypt_rsa);
    if ((int) uiInputLen >= rsa_len - 12)
    {
        int blockCnt = (uiInputLen / (rsa_len - 12)) + (((uiInputLen % (rsa_len - 12)) == 0) ? 0 : 1);
        finalLen = blockCnt * rsa_len;
        *ppOutput = (unsigned char *) calloc(finalLen, sizeof(unsigned char));
        if (*ppOutput == NULL)
        {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }

        for (; i < blockCnt; ++i)
        {
            int blockSize = rsa_len - 12;
            if (i == blockCnt - 1)
                blockSize = uiInputLen - i * blockSize;

            if (RSA_public_encrypt(blockSize, (pInput + i * (rsa_len - 12)), (*ppOutput + i * rsa_len), encrypt_rsa, RSA_PKCS1_PADDING) < 0)
            {
                unsigned long errorTrack = ERR_get_error() ;

                char buf[256] = {0};
                ERR_error_string(errorTrack, buf);
                printf("%s", buf);
                ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
                goto END;
            }
        }
        *uiOutputLen = finalLen;
    }
    else
    {
        *ppOutput = (unsigned char *) calloc(rsa_len, sizeof(unsigned char));
        if (*ppOutput == NULL)
        {
            ret = CRYPT_ERR_NO_MEMORY;
            goto END;
        }

        // encrypt (return the size of the encrypted data)
        // note that if RSA_PKCS1_OAEP_PADDING is used,
        // flen must be < RSA_size - 41
        if (RSA_public_encrypt(uiInputLen,
                               pInput, *ppOutput, encrypt_rsa, RSA_PKCS1_PADDING) < 0)
        {
            ret = CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY;
            goto END;
        }
        *uiOutputLen = rsa_len;
    }

END:
    if (CRYPT_OK != ret)
    {
        if (*ppOutput != NULL)
        {
            free(*ppOutput);
            ppOutput = NULL;
        }
    }
    RSA_free(encrypt_rsa);
    return ret;
}

/////
static int rsa_private_decrypt(unsigned char **_out, unsigned int *_outlen, const unsigned char *_in, unsigned int _inlen, RSA *_key)
{
    if (!_in || !_key || _inlen < 8 || _inlen % 8 != 0)
    {
        return __LINE__;
    }

    int ret = 0;

    // load priv key
    RSA *Rsa = _key;
    if (!Rsa)
    {
        return __LINE__;
    }
    unsigned int iKeySize = (unsigned int) RSA_size(Rsa);

    // decrypt
    unsigned char *pcPlainBuf = (unsigned char *) calloc(_inlen, sizeof(unsigned char));
    if (!pcPlainBuf)
    {
        return __LINE__;
    }
    int iPlainSize = 0;
    if (_inlen > (unsigned int) iKeySize)
    {
        unsigned int iBlockCnt = _inlen / iKeySize;

        unsigned int iPos = 0;
        unsigned int i = 0;
        for (i = 0; i < iBlockCnt; ++i)
        {
            unsigned int iBlockSize = 0;
            ret = RSA_private_decrypt(iKeySize, (const unsigned char *) _in + i * iKeySize, pcPlainBuf + iPos, Rsa, RSA_PKCS1_PADDING);
            if (ret < 1)
            {
                free(pcPlainBuf);
                return __LINE__;
            }
            iPos += ret;
        }

        iPlainSize = iPos;
    }
    else
    {
        ret = RSA_private_decrypt(iKeySize, (const unsigned char *) _in, pcPlainBuf, Rsa, RSA_PKCS1_PADDING);

        if (ret < 1)
        {
            free(pcPlainBuf);
            return __LINE__;
        }

        iPlainSize = ret;
    }

    *_out = pcPlainBuf;
    *_outlen = (unsigned int) iPlainSize;

    return 0;
}

/////////

typedef enum {
    kBufNotEnough,
    kOK,

} GenRsaKeyResult;

typedef enum {
    kKey512Bits = 512,
    kKey1024Bits = 1024,
    kKey2048Bits = 2048,
} RSAKeyBits;

static GenRsaKeyResult generate_rsa_key_pair(char *_pem_public_key_buf, const size_t _public_key_buf_len,
                                             char *_pem_private_key_buf, const size_t _private_key_buf_len, RSAKeyBits _key_bits)
{

    GenRsaKeyResult ret = kOK;
    /* 产生RSA密钥 */
    RSA *rsa = RSA_generate_key(_key_bits, RSA_F4, NULL, NULL);

    /* 提取私钥 */
    BIO *bio_private = BIO_new(BIO_s_mem());
    PEM_write_bio_RSAPrivateKey(bio_private, rsa, NULL, NULL, 0, NULL, NULL);
    int private_key_len = BIO_pending(bio_private);
    char *pem_private_key = (char *) calloc(private_key_len + 1, 1);
    BIO_read(bio_private, pem_private_key, private_key_len);
    //xdebug2(TSF"pem_private_key=%_, pem key len=%_",pem_private_key, strlen(pem_private_key));

    /* 提取公钥 */
    unsigned char *n_b = (unsigned char *) calloc(RSA_size(rsa),
                                                  sizeof(unsigned char));
    unsigned char *e_b = (unsigned char *) calloc(RSA_size(rsa),
                                                  sizeof(unsigned char));

    int n_size = BN_bn2bin(rsa->n, n_b);
    int b_size = BN_bn2bin(rsa->e, e_b);

    RSA *pubrsa = RSA_new();
    pubrsa->n = BN_bin2bn(n_b, n_size, NULL);
    pubrsa->e = BN_bin2bn(e_b, b_size, NULL);

    BIO *bio_public = BIO_new(BIO_s_mem());
    PEM_write_bio_RSA_PUBKEY(bio_public, pubrsa);
    int public_key_len = BIO_pending(bio_public);
    char *pem_public_key = (char *) calloc(public_key_len + 1, 1);
    BIO_read(bio_public, pem_public_key, public_key_len);

    if (_public_key_buf_len < strlen(pem_public_key) || _private_key_buf_len < strlen((const char *) &pem_private_key))
    {
        ret = kBufNotEnough;
        goto err;
    }
    memcpy(_pem_private_key_buf, pem_private_key, strlen(pem_private_key));
    memcpy(_pem_public_key_buf, pem_public_key, strlen(pem_public_key));

err:
    if (n_b != NULL)
    {
        free(n_b);
    }
    if (e_b != NULL)
    {
        free(e_b);
    }
    if (pem_public_key != NULL)
    {
        free(pem_public_key);
    }
    if (pem_private_key != NULL)
    {
        free(pem_private_key);
    }
    BIO_free(bio_private);
    BIO_free(bio_public);
    RSA_free(rsa);
    RSA_free(pubrsa);
    return ret;
}

static GenRsaKeyResult generate_rsa_key_pair_2048(char *_pem_public_key_buf, const size_t _public_key_buf_len,
                                                  char *_pem_private_key_buf, const size_t _private_key_buf_len)
{
    return generate_rsa_key_pair(_pem_public_key_buf, _public_key_buf_len, _pem_private_key_buf, _private_key_buf_len, kKey2048Bits);
}

static GenRsaKeyResult generate_rsa_key_pair_1024(char *_pem_public_key_buf, const size_t _public_key_buf_len,
                                                  char *_pem_private_key_buf, const size_t _private_key_buf_len)
{
    return generate_rsa_key_pair(_pem_public_key_buf, _public_key_buf_len, _pem_private_key_buf, _private_key_buf_len, kKey1024Bits);
}

@implementation FSOpenSSL

+ (NSData *)random128BitAESKey
{
    unsigned char buf[16];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

+ (NSString *)md5StringFromString:(NSString *)string
{
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[MD5_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    MD5(inStrg, lngth, result);

    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++)
    {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

+ (NSData *)md5DataFromData:(NSData *)data
{
    unsigned char *inStrg = (unsigned char *) [data bytes];
    unsigned long lngth = [data length];
    unsigned char result[MD5_DIGEST_LENGTH];
    
    MD5(inStrg, lngth, result);
    
    return [NSData dataWithBytes:result length:MD5_DIGEST_LENGTH];
}

+ (NSString *)md5StringFromData:(NSData *)data
{
    unsigned char *inStrg = (unsigned char *) [data bytes];
    unsigned long lngth = [data length];
    unsigned char result[MD5_DIGEST_LENGTH];
    
    MD5(inStrg, lngth, result);
    
    NSMutableString *outStrg = [NSMutableString string];
    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++)
    {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

+ (NSString *)sha256FromString:(NSString *)string
{
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSASCIIStringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[SHA256_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, inStrg, lngth);
    SHA256_Final(result, &sha256);

    unsigned int i;
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

+ (NSString *)sha1StringFromData:(NSData *)data
{
    NSData *sha1 = [self sha1DataFromData:data];
    NSMutableString *ms = [NSMutableString new];
    unsigned int i;
    for (i = 0; i < [sha1 length]; i++)
    {
        [ms appendFormat:@"%02x", ((Byte *)[sha1 bytes])[i]];
    }
    return [ms copy];
}

+ (NSData *)sha1DataFromData:(NSData *)data {
    unsigned char *inStrg = (unsigned char *) [data bytes];
    unsigned long lngth = [data length];
    unsigned char result[SHA_DIGEST_LENGTH] = {0};

    SHA_CTX sha256;
    SHA1_Init(&sha256);
    SHA1_Update(&sha256, inStrg, lngth);
    SHA1_Final(result, &sha256);

    NSData *r = [[NSData alloc] initWithBytes:result length:SHA_DIGEST_LENGTH];
    LogDebug(@"%@", r);
    return r;
}

+ (NSString *)base64FromString:(NSString *)string encodeWithNewlines:(BOOL)encodeWithNewlines
{
    BIO *mem = BIO_new(BIO_s_mem());
    BIO *b64 = BIO_new(BIO_f_base64());

    if (!encodeWithNewlines)
    {
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    }
    mem = BIO_push(b64, mem);

    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = stringData.length;
    void *buffer = (void *) [stringData bytes];
    int bufferSize = (int) MIN(length, INT_MAX);

    NSUInteger count = 0;

    BOOL error = NO;

    // Encode the data
    while (!error && count < length)
    {
        int result = BIO_write(mem, buffer, bufferSize);
        if (result <= 0)
        {
            error = YES;
        }
        else
        {
            count += result;
            buffer = (void *) [stringData bytes] + count;
            bufferSize = (int) MIN((length - count), INT_MAX);
        }
    }

    int flush_result = BIO_flush(mem);
    if (flush_result != 1)
    {
        return nil;
    }

    char *base64Pointer;
    NSUInteger base64Length = (NSUInteger) BIO_get_mem_data(mem, &base64Pointer);

    NSData *base64data = [NSData dataWithBytesNoCopy:base64Pointer length:base64Length freeWhenDone:NO];
    NSString *base64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];

    BIO_free_all(mem);
    return base64String;
}

+ (NSString *)base64FromData:(NSData *)stringData encodeWithNewlines:(BOOL)encodeWithNewlines
{
    BIO *mem = BIO_new(BIO_s_mem());
    BIO *b64 = BIO_new(BIO_f_base64());

    if (!encodeWithNewlines)
    {
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    }
    mem = BIO_push(b64, mem);

    NSUInteger length = stringData.length;
    void *buffer = (void *) [stringData bytes];
    int bufferSize = (int) MIN(length, INT_MAX);

    NSUInteger count = 0;

    BOOL error = NO;

    // Encode the data
    while (!error && count < length)
    {
        int result = BIO_write(mem, buffer, bufferSize);
        if (result <= 0)
        {
            error = YES;
        }
        else
        {
            count += result;
            buffer = (void *) [stringData bytes] + count;
            bufferSize = (int) MIN((length - count), INT_MAX);
        }
    }

    int flush_result = BIO_flush(mem);
    if (flush_result != 1)
    {
        return nil;
    }

    char *base64Pointer;
    NSUInteger base64Length = (NSUInteger) BIO_get_mem_data(mem, &base64Pointer);

    NSData *base64data = [NSData dataWithBytesNoCopy:base64Pointer length:base64Length freeWhenDone:NO];
    NSString *base64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];

    BIO_free_all(mem);
    return base64String;
}

//Calculates the length of a decoded string
static size_t sizeOfBase64DecodeLength(const char* b64input) {
    size_t len = strlen(b64input),
    padding = 0;

    if (b64input[len-1] == '=' && b64input[len-2] == '=') //last two chars are =
        padding = 2;
    else if (b64input[len-1] == '=') //last char is =
        padding = 1;

    return (len*3)/4 - padding;
}

static int base64DecodeWithString(const char* b64message, unsigned char** buffer, size_t* length) { //Decodes a base64 encoded string
    BIO *bio, *b64;
    int decodeLen = decodeLen = (int) sizeOfBase64DecodeLength(b64message);
    *buffer = (unsigned char*)malloc(decodeLen + 1);
    (*buffer)[decodeLen] = '\0';
    bio = BIO_new_mem_buf(b64message, -1);
    b64 = BIO_new(BIO_f_base64());
    bio = BIO_push(b64, bio);
    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL); //Do not use newlines to flush buffer
    *length = BIO_read(bio, *buffer, (int) strlen(b64message));
    assert(*length == decodeLen); //length should equal decodeLen, else something went horribly wrong
    BIO_free_all(bio);
    return 0; //success
}

+ (NSData *)base64decodeFromString:(NSString *)base64String {
    const char * buf = [base64String cStringUsingEncoding:NSUTF8StringEncoding];
    char *base64DecodeOutput ;
    size_t lengthAfterDecode;
    
    base64DecodeWithString(buf, (unsigned char**)&base64DecodeOutput, &lengthAfterDecode);
    
    return [NSData dataWithBytes:base64DecodeOutput length:lengthAfterDecode];
}

+ (NSData *)RSAEncryptData:(NSData *)data modulus:(NSData *)modules exponent:(NSData *)exponent
{
    unsigned char *output;
    unsigned int outputLen;
    int ret = rsa_public_encrypt([data bytes], (unsigned int) [data length], &output, &outputLen, modules, exponent);
    if (ret == CRYPT_OK)
    {
        return [NSData dataWithBytes:output length:outputLen];
    }

    return nil;
}

size_t const kKeySize = kCCKeySizeAES128;

NSData *cipherOperation(NSData *contentData, NSData *keyData, CCOperation operation)
{
    NSUInteger dataLength = contentData.length;

    void const *initVectorBytes = keyData.bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;

    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL)
    {
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

    if (cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

+ (NSData *)aesEncryptData:(NSData *)contentData key:(NSData *)keyData
{
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);

    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCEncrypt);
}

+ (NSData *)aesDecryptData:(NSData *)contentData key:(NSData *)keyData
{
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);

    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCDecrypt);
}

//

+ (NSData *)RSA_PUB_EncryptData:(NSData *)data modulus:(NSString *)modules exponent:(NSString *)exponent
{
    unsigned char *output;
    unsigned int outputLen;
    int ret = rsa_public_encrypt1([data bytes], (unsigned int) [data length], &output, &outputLen, [modules UTF8String], [exponent UTF8String]);
    if (ret == CRYPT_OK)
    {
        return [NSData dataWithBytes:output length:outputLen];
    }

    return nil;
}

+ (BOOL)genRSAKeyPairPubKey:(NSString **)rsaPubKey priKey:(NSString **)rsaPriKey
{
    char pubKeyBuf[2048] = {0};
    char priKeyBuf[2028] = {0};
    GenRsaKeyResult ret = generate_rsa_key_pair_1024(pubKeyBuf, 2048, priKeyBuf, 2048);
    if (ret == kOK)
    {
        *rsaPubKey = [NSString stringWithCString:pubKeyBuf encoding:NSUTF8StringEncoding];
        *rsaPriKey = [NSString stringWithCString:priKeyBuf encoding:NSUTF8StringEncoding];
        return YES;
    }
    
    return NO;
}

+ (NSString *)data2HexString:(NSData *)data {
    unsigned char *result = (unsigned char *) [data bytes];
    
    NSMutableString *outStrg = [NSMutableString string];
    unsigned int i;
    for (i = 0; i < [data length]; i++)
    {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

@end
