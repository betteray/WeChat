//
//  NSData+Compress.h
//  WXDemo
//
//  Created by ray on 2018/9/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Compress)

- (NSData*) compresss;
- (NSData*) decompress: (unsigned) length;

@end
