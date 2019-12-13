
//
//  AesGcm.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#include <openssl/rand.h>
#include <openssl/pem.h>

#define AES_256_IVEC_LENGTH 12

@implementation WC_AesGcm128

// encrypt plaintext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec
+ (NSData *)aes128gcmEncrypt:(NSData *)plaintext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;
{
    int status = 0;
    NSMutableData *ciphertext = [NSMutableData dataWithLength:[plaintext length]];
    if (!ciphertext)
    {
        LogError(@"New Ciphertest failed.");
        return nil;
    }
    // set up to Encrypt AES 128 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_aes_128_gcm(), NULL, NULL, NULL);

    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    EVP_EncryptInit_ex(ctx, NULL, NULL, [key bytes], [ivec bytes]);

    EVP_CIPHER_block_size(ctx->cipher);

    // add optional AAD (Additional Auth Data)
    if (aad)
        status = EVP_EncryptUpdate(ctx, NULL, &numberOfBytes, [aad bytes], (int) [aad length]);

    unsigned char *ctBytes = [ciphertext mutableBytes];
    EVP_EncryptUpdate(ctx, ctBytes, &numberOfBytes, [plaintext bytes], (int) [plaintext length]);
    status = EVP_EncryptFinal_ex(ctx, ctBytes + numberOfBytes, &numberOfBytes);
    if (!status)
    {
        LogError(@"Encrypt Error: %d", status);
    }

    unsigned char buf[16];
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, buf);
    NSData *tag = [NSData dataWithBytes:buf length:16];
    [ciphertext appendData:tag];

    EVP_CIPHER_CTX_free(ctx);
    return ciphertext; // OpenSSL uses 1 for success
}

+ (NSData *)aes192gcmEncrypt:(NSData *)plaintext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec;
{
    int status = 0;
    NSMutableData *ciphertext = [NSMutableData dataWithLength:[plaintext length]];
    if (!ciphertext)
    {
        LogError(@"New Ciphertest failed.");
        return nil;
    }
    // set up to Encrypt AES 128 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_aes_192_gcm(), NULL, NULL, NULL);

    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    EVP_EncryptInit_ex(ctx, NULL, NULL, [key bytes], [ivec bytes]);

    EVP_CIPHER_block_size(ctx->cipher);

    // add optional AAD (Additional Auth Data)
    if (aad)
        status = EVP_EncryptUpdate(ctx, NULL, &numberOfBytes, [aad bytes], (int) [aad length]);

    unsigned char *ctBytes = [ciphertext mutableBytes];
    EVP_EncryptUpdate(ctx, ctBytes, &numberOfBytes, [plaintext bytes], (int) [plaintext length]);
    status = EVP_EncryptFinal_ex(ctx, ctBytes + numberOfBytes, &numberOfBytes);
    if (!status)
    {
        LogError(@"Encrypt Error: %d", status);
    }

    [ciphertext appendData:ivec];
    
    unsigned char buf[16];
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, buf);
    NSData *tag = [NSData dataWithBytes:buf length:16];
    [ciphertext appendData:tag];

    EVP_CIPHER_CTX_free(ctx);
    return ciphertext; // OpenSSL uses 1 for success
}

// decrypt ciphertext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec
+ (NSData *)aes128gcmDecrypt:(NSData *)ciphertext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec
{

    int status = 0;

    if (!ciphertext || !key || !ivec)
        return nil;

    NSMutableData *plaintext = [NSMutableData dataWithLength:[ciphertext length]];
    if (!plaintext)
        return nil;

    // set up to Decrypt AES 128 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_DecryptInit_ex(ctx, EVP_aes_128_gcm(), NULL, NULL, NULL);

    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    status = EVP_DecryptInit_ex(ctx, NULL, NULL, [key bytes], [ivec bytes]);

    // add optional AAD (Additional Auth Data)
    if (aad)
        EVP_DecryptUpdate(ctx, NULL, &numberOfBytes, [aad bytes], (int) [aad length]);

    status = EVP_DecryptUpdate(ctx, [plaintext mutableBytes], &numberOfBytes, [ciphertext bytes], (int) [ciphertext length]);
    if (!status)
    { // OpenSSL uses 1 for success
        LogError(@"Decrypt Error: %d", status);
    }

    EVP_DecryptFinal_ex(ctx, NULL, &numberOfBytes);
    EVP_CIPHER_CTX_free(ctx);

    return [plaintext subdataWithRange:NSMakeRange(0, [plaintext length] - 16)];
}

+ (NSData *)aes192gcmDecrypt:(NSData *)ciphertext
                         aad:(NSData *)aad
                         key:(NSData *)key
                        ivec:(NSData *)ivec
{
    
    int status = 0;
    
    if (!ciphertext || !key || !ivec)
        return nil;
    
    NSMutableData *plaintext = [NSMutableData dataWithLength:[ciphertext length]];
    if (!plaintext)
        return nil;
    
    // set up to Decrypt AES 192 GCM
    int numberOfBytes = 0;
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_DecryptInit_ex(ctx, EVP_aes_192_gcm(), NULL, NULL, NULL);
    
    // set the key and ivec
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, AES_256_IVEC_LENGTH, NULL);
    status = EVP_DecryptInit_ex(ctx, NULL, NULL, [key bytes], [ivec bytes]);
    
    // add optional AAD (Additional Auth Data)
    if (aad)
        EVP_DecryptUpdate(ctx, NULL, &numberOfBytes, [aad bytes], (int) [aad length]);
    
    status = EVP_DecryptUpdate(ctx, [plaintext mutableBytes], &numberOfBytes, [ciphertext bytes], (int) [ciphertext length]);
    if (!status)
    { // OpenSSL uses 1 for success
        LogError(@"Decrypt Error: %d", status);
    }
    
    EVP_DecryptFinal_ex(ctx, NULL, &numberOfBytes);
    EVP_CIPHER_CTX_free(ctx);
    
    return plaintext;
}

@end
