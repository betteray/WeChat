//
//  NSData+PackUtil.m
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+PackUtil.h"
#import "WeChatClient.h"
#import "FSOpenSSL.h"
#import "NSData+Util.h"

@implementation NSData (PackUtil)

- (NSData *)aesDecrypt {
    return [FSOpenSSL aesDecryptData:self key:[WeChatClient sharedClient].aesKey];
}

- (NSData *)aesDecrypt_then_decompress {
    NSData *decryptedData = [FSOpenSSL aesDecryptData:self key:[WeChatClient sharedClient].aesKey];
    return [decryptedData decompress];
}

@end
