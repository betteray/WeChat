//
//  NSData+PackUtil.h
//  WXDemo
//
//  Created by ray on 2018/9/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (PackUtil)

- (NSData *)aesDecrypt;

- (NSData *)aesDecrypt_then_decompress;

@end
