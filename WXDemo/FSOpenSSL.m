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

@implementation FSOpenSSL

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

+ (NSData *)RSAEncryptString:(NSData *)data modulus:(NSData *)modules exponent:(NSData *)exponent
{
    RSA *r;
    BIGNUM *bne, *bnn;//rsa算法中的 e和N
    int blockLen;//每次最大加密字节数
    unsigned char *encodeData;//加密后的数据
    
    bnn = BN_new();
    bne = BN_new();
    
    r = RSA_new();
    //看到网上有人用BN_hex2bn这个函数来转化的，但我用这个转化总是失败，最后选择了BN_bin2bn
    r->e = BN_bin2bn([exponent bytes], (int)[exponent length], bne);
    r->n = BN_bin2bn([modules bytes], (int)[modules length], bnn);
    
    blockLen = RSA_size(r) - 11;// 公钥长度/8 - 11
    encodeData = (unsigned char *)malloc(blockLen);
    bzero(encodeData, blockLen);
    //由于需要加密的内容都在最大加密长度内，所以我没有分块，如果你的文本内容长度超过了blockLen，请分块处理，然后拼接起来
    int ret = RSA_public_encrypt((int)[data length], (unsigned char *)[data bytes], encodeData, r, RSA_PKCS1_PADDING);
    //这里的 RSA_PKCS1_PADDING选择的不同，对应的最大加密长度就不一样，当时在网上看到过，现在找不到了，你们自己上网找找吧
    
    RSA_free(r);
    if(ret < 0)
    {
        NSLog(@"encrypt failed !");
        return nil;
    }
    else
    {
        NSData *result = [NSData dataWithBytes: encodeData   length:ret];
        free(encodeData);
        return result;
        
    }
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
