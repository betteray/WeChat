//
//  NSData+Compression.m
//  WXDemo
//
//  Created by ray on 2018/9/18.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+Compression.h"
#include <zlib.h>

NSString *const BBZlibErrorDomain = @"se.bitba.ZlibErrorDomain";
static const size_t CHUNK = 65536;

@implementation NSData (Compression)

- (NSData *)dataByInflatingWithError:(NSError *__autoreleasing *)error
{
    if (![self length])
        return [self copy];
    NSMutableData *outData = [NSMutableData data];
    [self inflate:^(NSData *toAppend) {
        [outData appendData:toAppend];
    }
            error:error];
    return outData;
}

- (NSData *)dataByDeflating
{
    if (![self length])
        return [self copy];
    NSMutableData *outData = [NSMutableData data];
    [self deflate:^(NSData *toAppend) {
        [outData appendData:toAppend];
    }];
    return outData;
}

- (BOOL)inflate:(void (^)(NSData *))processBlock
          error:(NSError *__autoreleasing *)error
{
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = 0;
    stream.next_in = Z_NULL;

    int ret = inflateInit(&stream);
    NSCAssert(ret == Z_OK, @"Could not init deflate");
    Bytef *source = (Bytef *) [self bytes]; // yay
    uInt offset = 0;
    uInt len = (uInt)[self length];

    do
    {
        stream.avail_in = (uint) MIN(CHUNK, len - offset);
        if (stream.avail_in == 0)
            break;
        stream.next_in = source + offset;
        offset += stream.avail_in;
        do
        {
            Bytef out[CHUNK];
            stream.avail_out = CHUNK;
            stream.next_out = out;
            ret = inflate(&stream, Z_NO_FLUSH);
            NSCAssert(ret != Z_STREAM_ERROR, @"Error");
            switch (ret)
            {
                case Z_NEED_DICT:
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                    inflateEnd(&stream);
                    if (error)
                        *error = [NSError errorWithDomain:BBZlibErrorDomain
                                                     code:BBZlibErrorCodeInflationError
                                                 userInfo:nil];
                    return NO;
            }
            processBlock([NSData dataWithBytesNoCopy:out
                                              length:CHUNK - stream.avail_out
                                        freeWhenDone:NO]);
        } while (stream.avail_out == 0);
    } while (ret != Z_STREAM_END);

    inflateEnd(&stream);
    return YES;
}

- (void)deflate:(void (^)(NSData *))processBlock
{
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;

    int ret = deflateInit(&stream, 9);
    NSCAssert(ret == Z_OK, @"Could not init deflate");
    Bytef *source = (Bytef *) [self bytes]; // yay
    uInt offset = 0;
    uInt len = (uInt)[self length];
    int flush;

    do
    {
        stream.avail_in = (uint) MIN(CHUNK, len - offset);
        stream.next_in = source + offset;
        offset += stream.avail_in;
        flush = offset > len - 1 ? Z_FINISH : Z_NO_FLUSH;
        do
        {
            Bytef out[CHUNK];
            stream.avail_out = CHUNK;
            stream.next_out = out;
            ret = deflate(&stream, flush);
            NSAssert(ret != Z_STREAM_ERROR, @"Error");
            processBlock([NSData dataWithBytesNoCopy:out
                                              length:CHUNK - stream.avail_out
                                        freeWhenDone:NO]);
        } while (stream.avail_out == 0);
        NSAssert(stream.avail_in == 0, @"Error");
    } while (flush != Z_FINISH);
    NSAssert(ret == Z_STREAM_END, @"Error");
    deflateEnd(&stream);
}

@end
