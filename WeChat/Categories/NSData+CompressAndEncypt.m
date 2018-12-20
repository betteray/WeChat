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
#import "WeChatClient.h"
#import "FSOpenSSL.h"
#import "NSData+Compression.h"
#import "NSData+AES.h"

@implementation NSData (CompressAndEncypt)

//Send
- (NSData *)Compress_And_RSA
{
    NSData *compressedData = [self dataByDeflating];
    return [FSOpenSSL RSA_PUB_EncryptData:compressedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
}

- (NSData *)RSA
{
    return [FSOpenSSL RSA_PUB_EncryptData:self modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
}

- (NSData *)Compress_And_AES
{
    NSData *compressedData = [self dataByDeflating];
    NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
    return [compressedData AES_CBC_encryptWithKey:sessionKey];
}

- (NSData *)AES
{
    NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
    return [self AES_CBC_encryptWithKey:sessionKey];
}

@end
