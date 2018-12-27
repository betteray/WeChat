//
//  NSData+CompressAndEncypt.m
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+CompressAndEncypt.h"

#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "Constants.h"
#import "NSData+Compression.h"
#import "NSData+AES.h"

@implementation NSData (CompressAndEncypt)

//Send
- (NSData *)Compress_And_RSA
{
    NSData *compressedData = [self dataByDeflating];
    return [FSOpenSSL RSA_PUB_EncryptData:compressedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
}

- (NSData *)Compress_And_AES
{
    NSData *compressedData = [self dataByDeflating];
    return [compressedData AES_CBC_encryptWithKey:[WeChatClient sharedClient].sessionKey];
}

- (NSData *)AES
{
    return [self AES_CBC_encryptWithKey:[WeChatClient sharedClient].sessionKey];
}


- (NSData *)aesDecryptWithKey:(NSData *)key
{
    return [self AES_CBC_decryptWithKey:key];
}

- (NSData *)aesDecrypt_then_decompress
{
    NSData *decryptedData = [self AES_CBC_decryptWithKey:[WeChatClient sharedClient].sessionKey];
    return [decryptedData dataByInflatingWithError:nil];
}

@end
