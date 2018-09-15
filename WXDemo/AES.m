//
//  AES.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "AES.h"

@implementation AES

+ (NSData *)random128BitAESKey {
    unsigned char buf[16];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

@end
