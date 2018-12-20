//
//  NSData+Endian.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+Util.h"
#import <zlib.h>

@implementation NSData (Util)

- (int32_t)toInt32ofRange:(NSRange)range SwapBigToHost:(BOOL)swap{
    int32_t int32 = *(int32_t*)([[self subdataWithRange:range] bytes]);
    return swap ? CFSwapInt32BigToHost(int32) : int32;
}

- (int16_t)toInt16ofRange:(NSRange)range SwapBigToHost:(BOOL)swap {
    int16_t int16 = *(int16_t*)([[self subdataWithRange:range] bytes]);
    return swap ? CFSwapInt16BigToHost(int16) : int16;
}

- (int)toInt8ofRange:(NSInteger)location {
    NSData *subData = [self subdataWithRange:NSMakeRange(location, 1)];
    return * (int*) ([subData bytes]);
}

//Pack
+ (NSData *)packInt32:(int32_t)int32 flip:(BOOL)flip {
    int32_t realInt32 = int32;
    if (flip) {
        return [[[NSData alloc] initWithBytes:&realInt32 length:sizeof(realInt32)] bytesFlip];
    } else {
        return [[NSData alloc] initWithBytes:&realInt32 length:sizeof(realInt32)];
    }
}

+ (NSData *)packInt16:(int16_t)int16 flip:(BOOL)flip {
    if (flip) {
        return [[[NSData alloc] initWithBytes:&int16 length:sizeof(int16_t)] bytesFlip];
    } else {
        return [[NSData alloc] initWithBytes:&int16 length:sizeof(int16_t)];
    }
}

+ (NSData *)packInt8:(int8_t)int8
{
    return [[NSData alloc] initWithBytes:&int8 length:sizeof(int8_t)];
}

+ (NSData *)a:(int)int32 {
    return [[self dataWithHexString:[NSString stringWithFormat:@"%x", int32]] bytesFlip];
}

+ (NSData *)varintBytes:(int)int32 {
    
    NSMutableData *varintBytes = [NSMutableData data];
    while (int32 >= 0x80) {
        [varintBytes appendData:[NSData a:(0x80 + (int32 & 0x7f))]];
        int32 = int32 >> 7;
    }
    [varintBytes appendData:[NSData a:int32]];
    
    return varintBytes;
}

+ (instancetype)dataWithHexString:(NSString *)string {
    return [[self alloc] initWithHexString:string];
}

- (instancetype)initWithHexString:(NSString *)string {
    
    if (!string || [string length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([string length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [string length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [string substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
// 将NSData转换成十六进制的字符串
- (NSString *)toHexString {
    
    if (!self || [self length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
    
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}


// 字节翻转
- (NSData *)bytesFlip {
    const char *bytes = [self bytes];
    NSInteger idx = [self length] - 1;
    char *reversedBytes = calloc(sizeof(char),[self length]);
    for (int i = 0; i < [self length]; i++) {
        reversedBytes[idx--] = bytes[i];
    }
    NSData *reversedData = [NSData dataWithBytes:reversedBytes length:[self length]];
    free(reversedBytes);
    return reversedData;
}


// zlib
enum { compressed_signature = 'zdat' };

- (NSData*)decompress
{
    if ([self length] == 0) return self;
    unsigned full_length = (uint)[self length];
    unsigned half_length = (uint)([self length] / 2);
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    
    BOOL done = NO;
    int status;
    z_stream strm;

    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = (uint)[self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uint)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

@end
