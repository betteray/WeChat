//
//  NSData+CompressAndEncypt.m
//  WXDemo
//
//  Created by ray on 2018/9/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+CompressAndEncypt.h"

#import "NSData+Util.h"
#import "MarsOpenSSL.h"
#import "Constants.h"
#import "WeChatClient.h"
#import "FSOpenSSL.h"
#import "NSData+Compression.h"

@implementation NSData (CompressAndEncypt)

//Send
- (NSData *)Compress_And_RSA {
    NSData *compressedData = [self dataByDeflating];
    return [MarsOpenSSL RSA_PUB_EncryptData:compressedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
}

- (NSData *)RSA {
    return [MarsOpenSSL RSA_PUB_EncryptData:self modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
}

- (NSData *)Compress_And_AES {
    NSData *compressedData = [self dataByDeflating];
    return [FSOpenSSL aesEncryptData:compressedData key:[WeChatClient sharedClient].sessionKey];
}

- (NSData *)AES {
    return [FSOpenSSL aesEncryptData:self key:[WeChatClient sharedClient].sessionKey];
}

//Receive
- (NSData *)decompress_and_aesDecrypt {
    NSData *deCompressedData = [self decompress];
    return [FSOpenSSL aesDecryptData:deCompressedData key:[WeChatClient sharedClient].sessionKey];
}

- (NSData *)aesDecrypt {
    return [FSOpenSSL aesDecryptData:self key:[WeChatClient sharedClient].sessionKey];
}

@end
