//
//  NSData+PackUtil.m
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+PackUtil.h"
#import "WeChatClient.h"
#import "NSData+Util.h"
#import "NSData+AES.h"

@implementation NSData (PackUtil)

- (NSData *)aesDecryptWithKey:(NSData *)key
{
    return [self AES_CBC_decryptWithKey:key];
}

- (NSData *)aesDecrypt_then_decompress
{
    NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
    NSData *decryptedData = [self AES_CBC_decryptWithKey:sessionKey];
    return [decryptedData decompress];
}

@end
