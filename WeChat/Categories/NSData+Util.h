//
//  NSData+Endian.h
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Util)

- (instancetype)initWithHexString:(NSString *)string;
+ (instancetype)dataWithHexString:(NSString *)string;

+ (NSData *)packInt32:(int32_t)int32 flip:(BOOL)flip;
+ (NSData *)packInt16:(int16_t)int16 flip:(BOOL)flip;
+ (NSData *)packInt8:(int8_t)int8;

+ (NSData *)varintBytes:(int)int32;

- (NSString *)toHexString;
- (NSData *)bytesFlip;

//unpack
- (int)toInt8ofRange:(NSInteger)location;
- (uint16_t)toInt16ofRange:(NSRange)range SwapBigToHost:(BOOL)swap;
- (int32_t)toInt32ofRange:(NSRange)range SwapBigToHost:(BOOL)swap;

@end
