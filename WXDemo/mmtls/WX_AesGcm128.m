//
//  AesGcm.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WX_AesGcm128.h"

#include <openssl/rand.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/evp.h>

#define AES_256_IVEC_LENGTH     12

@implementation WX_AesGcm128

// encrypt plaintext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec
+ (BOOL) aes128gcmEncrypt:(NSData*)plaintext
               ciphertext:(NSMutableData**)ciphertext
                      aad:(NSData*)aad
                      key:(NSData*)key
                     ivec:(NSData*)ivec;
{

    int status = 0;
    *ciphertext = [NSMutableData dataWithLength:[plaintext length]];
    if (! *ciphertext)
        return NO;
    
    // set up to Encrypt AES 128 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex (ctx, EVP_aes_128_gcm(), NULL, NULL, NULL);
    
    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    EVP_EncryptInit_ex (ctx, NULL, NULL, [key bytes], [ivec bytes]);
    
    EVP_CIPHER_block_size(ctx->cipher);
    
    // add optional AAD (Additional Auth Data)
    if (aad)
        status = EVP_EncryptUpdate( ctx, NULL, &numberOfBytes, [aad bytes], (int)[aad length]);
    
    unsigned char * ctBytes = [*ciphertext mutableBytes];
    EVP_EncryptUpdate (ctx, ctBytes, &numberOfBytes, [plaintext bytes], (int)[plaintext length]);
    status = EVP_EncryptFinal_ex (ctx, ctBytes+numberOfBytes, &numberOfBytes);
    
    unsigned char buf[16];
    EVP_CIPHER_CTX_ctrl (ctx, EVP_CTRL_GCM_GET_TAG, 16, buf);
    NSData *tag = [NSData dataWithBytes:buf length:16];
    [*ciphertext appendData:tag];
    
    EVP_CIPHER_CTX_free(ctx);
    return (status != 0); // OpenSSL uses 1 for success
}


// decrypt ciphertext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec
+ (BOOL) aes128gcmDecrypt:(NSData*)ciphertext
                plaintext:(NSData**)outPlaintext
                      aad:(NSData*)aad
                      key:(NSData*)key
                     ivec:(NSData*)ivec
{
    
    int status = 0;
    
    if (! ciphertext || !outPlaintext || !key || !ivec)
        return NO;
    
    NSMutableData *plaintext = [NSMutableData dataWithLength:[ciphertext length]];
    if (! plaintext)
        return NO;
    
    // set up to Decrypt AES 128 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_DecryptInit_ex (ctx, EVP_aes_128_gcm(), NULL, NULL, NULL);
    
    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    status = EVP_DecryptInit_ex (ctx, NULL, NULL, [key bytes], [ivec bytes]);
    
    // add optional AAD (Additional Auth Data)
    if (aad)
        EVP_DecryptUpdate(ctx, NULL, &numberOfBytes, [aad bytes], (int)[aad length]);
    
    status = EVP_DecryptUpdate (ctx, [plaintext mutableBytes], &numberOfBytes, [ciphertext bytes], (int)[ciphertext length]);
    if (! status) {
        //DDLogError(@"aes256gcmDecrypt: EVP_DecryptUpdate failed");
        return NO;
    }
    EVP_DecryptFinal_ex (ctx, NULL, &numberOfBytes);
    EVP_CIPHER_CTX_free(ctx);
    
    *outPlaintext = [plaintext subdataWithRange:NSMakeRange(0, [plaintext length]-16)];
    return (status != 0); // OpenSSL uses 1 for success
}

@end
