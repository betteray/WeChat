//
//  AES_EVP.m
//  WeChat
//
//  Created by ray on 2019/12/5.
//  Copyright © 2019 ray. All rights reserved.
//

#import "AES_EVP.h"
#include <openssl/evp.h>

@implementation AES_EVP

static int decrypt_aes_128_ecb(unsigned char* input, unsigned int input_len,
                        unsigned char* output,  unsigned int outbuf_len,
                        unsigned char* key, int padding) {
  int outlen, finallen, ret;
  EVP_CIPHER_CTX ctx;
  EVP_CIPHER_CTX_init(&ctx);
  EVP_DecryptInit(&ctx, EVP_aes_128_ecb(), key, 0);
  if (padding == 0)
    EVP_CIPHER_CTX_set_padding(&ctx, padding);
  if (!(ret = EVP_DecryptUpdate(&ctx, output, &outlen, input, input_len))) {
    printf("DecryptUpdate Error %d\n", ret);
    return 0;
  }
  if (!(ret = EVP_DecryptFinal(&ctx, output + outlen, &finallen))) {
    printf("DecryptFinal Error %d\n", ret);
    return 0;
  }
  EVP_CIPHER_CTX_cleanup(&ctx);
  return outlen + finallen;
}

static NSData * aes_128_ecb_encrypt(unsigned char* plaintext, int plaintext_len, unsigned char* key){
    EVP_CIPHER_CTX *ctx;
    
    NSMutableData *out = [NSMutableData dataWithLength:plaintext_len + 32]; // 要多出几个字节来放结果，最后截一下，还不知道咋处理，只是能工作。。。
    unsigned char* ciphertext = [out mutableBytes];
    int len;
    int ciphertext_len;

    if (!(ctx = EVP_CIPHER_CTX_new()))
        return nil;

    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_ecb(), NULL, key, NULL))
        return nil;
    if (1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len))
        return nil;
    ciphertext_len = len;
    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len))
        return nil;
    ciphertext_len += len;

    EVP_CIPHER_CTX_free(ctx);
    return [out subdataWithRange:NSMakeRange(0, ciphertext_len)]; // 截掉多余字节
}

static NSData * aes_128_cbc_encrypt(unsigned char* plaintext, int plaintext_len, unsigned char* key){
    EVP_CIPHER_CTX *ctx;
    
    NSMutableData *out = [NSMutableData dataWithLength:plaintext_len + 32]; // 要多出几个字节来放结果，最后截一下，还不知道咋处理，只是能工作。。。
    unsigned char* ciphertext = [out mutableBytes];
    int len;
    int ciphertext_len;

    if (!(ctx = EVP_CIPHER_CTX_new()))
        return nil;

    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, key))
        return nil;
    if (1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len))
        return nil;
    ciphertext_len = len;
    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len))
        return nil;
    ciphertext_len += len;

    EVP_CIPHER_CTX_free(ctx);
    return [out subdataWithRange:NSMakeRange(0, ciphertext_len)]; // 截掉多余字节
}

+ (NSData *)AES_ECB_128_Encrypt:(NSData *)plainText key:(NSData *)key {
    
    return  aes_128_ecb_encrypt((unsigned char*) [plainText bytes],
                                  (unsigned int) [plainText length],
                                  (unsigned char*)[key bytes]);
}

+ (NSData *)AES_CBC_128_Encrypt:(NSData *)plainText key:(NSData *)key {
    
    return  aes_128_cbc_encrypt((unsigned char*) [plainText bytes],
                                  (unsigned int) [plainText length],
                                  (unsigned char*)[key bytes]);
}

+ (NSString *)encrypedUserName:(NSString *)plainText WithKey:(NSString *)key {
    NSData *data = [AES_EVP AES_CBC_128_Encrypt:[plainText dataUsingEncoding:NSUTF8StringEncoding] key:[key dataUsingEncoding:NSUTF8StringEncoding]];
    return [data toHexString];
}

@end
