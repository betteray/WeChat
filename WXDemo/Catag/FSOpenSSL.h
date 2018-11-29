//
//  FSOpenSSL.h
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

#import <Foundation/Foundation.h>

enum
{
    CRYPT_OK = 0,
    CRYPT_ERR_INVALID_KEY_N = 1,
    CRYPT_ERR_INVALID_KEY_E = 2,
    CRYPT_ERR_ENCRYPT_WITH_RSA_PUBKEY = 3,
    CRYPT_ERR_DECRYPT_WITH_RSA_PRIVKEY = 4,
    CRYPT_ERR_NO_MEMORY = 5,
    CRYPT_ERR_ENCRYPT_WITH_DES_KEY = 6,
    CRYPT_ERR_DECRYPT_WITH_DES_KEY = 7,
    CRYPT_ERR_INVALID_PARAM = 8,
    CRYPT_ERR_LOAD_RSA_PRIVATE_KEY = 9,
};

@interface FSOpenSSL : NSObject

+ (NSData *)random128BitAESKey;

+ (NSString *)md5FromString:(NSString *)string;

+ (NSString *)sha256FromString:(NSString *)string;

+ (NSString *)base64FromString:(NSString *)string encodeWithNewlines:(BOOL)encodeWithNewlines;

+ (NSData *)RSAEncryptData:(NSData *)data modulus:(NSData *)modules exponent:(NSData *)exponent;

+ (NSData *) aesEncryptData:(NSData *)contentData key:(NSData *)keyData;
+ (NSData *) aesDecryptData:(NSData *)contentData key:( NSData *)keyData;

@end
