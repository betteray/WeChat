//
//  NSData+AES.h
//  WXDemo
//
//  Created by ray on 2018/9/21.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES_CBC_encryptWithKey:(NSData *)aesKey;
- (NSData *)AES_CBC_decryptWithKey:(NSData *)aesKey;

@end
