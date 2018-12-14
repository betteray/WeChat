//
//  NSData+Compress.m
//  WXDemo
//
//  Created by ray on 2018/9/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+Compress.h"
#import <zlib.h>

@implementation NSData (Compress)

- (NSData*) compresss
{
    uLong n = compressBound(self.length);
    unsigned char b[n];
    return ((compress2(b, &n, self.bytes, self.length, 9) == Z_OK)
            ? [NSData dataWithBytes: b length: n]
            : nil);
}

- (NSData*) decompress: (unsigned) length
{
    uLong n = length;
    unsigned char b[n];
    return ((uncompress(b, &n, self.bytes, self.length) == Z_OK)
            ? [NSData dataWithBytes: b length: n]
            : nil);
}

@end
