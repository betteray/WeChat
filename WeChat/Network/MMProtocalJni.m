//
//  MMProtocalJni.m
//  WeChat
//
//  Created by ysh on 2019/7/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MMProtocalJni.h"
#import "FSOpenSSL.h"
#include <zlib.h>

@implementation MMProtocalJni

+ (int)genSignatureWithUin:(int)uin
                   ecdhKey:(NSData *)ecdhKey
              protofufData:(NSData *)probufData
{
    NSData *data = [NSData packInt32:uin flip:YES];
    data = [data addDataAtTail:ecdhKey];
    NSData *md5result = [FSOpenSSL md5FromData:data];
    
    data = [NSData packInt32:(int) [probufData length] flip:YES];
    data = [data addDataAtTail:ecdhKey];
    data = [data addDataAtTail:md5result];
    md5result = [FSOpenSSL md5FromData:data];
    
    uLong adler = adler32(0L, Z_NULL, 0);
    adler = adler32(adler, [md5result bytes], (uInt) [md5result length]);
    adler = adler32(adler, [probufData bytes], (uInt) [probufData length]);
    
    return (int) adler;
}

@end
