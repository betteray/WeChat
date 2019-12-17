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

    int ret = deflateInit(&stream, Z_DEFAULT_COMPRESSION); //9
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



/////
// https://github.com/surespot/surespot-ios/blob/e3dceab286dd4793bc9cbf93b37c129910b6cd91/surespot/libs/NSData%2BGunzip.m

- (NSData *)gunzippedData
{
    if ([self length])
    {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uint)[self length];
        stream.next_in = (Bytef *)[self bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        NSMutableData *data = [NSMutableData dataWithLength: [self length] * 1.5];
        if (inflateInit2(&stream, 47) == Z_OK)
        {
            int status = Z_OK;
            while (status == Z_OK)
            {
                if (stream.total_out >= [data length])
                {
                    data.length += [self length] * 0.5;
                }
                stream.next_out = [data mutableBytes] + stream.total_out;
                stream.avail_out = (uint)([data length] - stream.total_out);
                status = inflate (&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK)
            {
                if (status == Z_STREAM_END)
                {
                    data.length = stream.total_out;
                    return data;
                }
            }
        }
    }
    return nil;
}

- (NSData*)gunzip:(NSError *__autoreleasing *)error
{
    /*
     * A minimal gzip header/trailer is 18 bytes long.
     * See: RFC 1952 http://www.gzip.org/zlib/rfc-gzip.html
     */
    if(self.length < 18)
    {
        if(error)
            *error = [NSError errorWithDomain:BBZlibErrorDomain code:Z_DATA_ERROR userInfo:nil];
        return nil;
    }
    z_stream zStream;
    memset(&zStream, 0, sizeof(zStream));
    /*
     * 16 is a magic number that allows inflate to handle gzip
     * headers.
     */
    int iResult = inflateInit2(&zStream, 16);
    if(iResult != Z_OK)
    {
        if(error)
            *error = [NSError errorWithDomain:BBZlibErrorDomain code:iResult userInfo:nil];
        return nil;
    }
    /*
     * The last four bytes of a gzipped file/buffer contain the the number
     * of uncompressed bytes expressed as a 32-bit little endian unsigned integer.
     * See: RFC 1952 http://www.gzip.org/zlib/rfc-gzip.html
     */
    //UInt32 nUncompressedBytes = *(UInt32*)([self bytes] + self.length - 4);
    
    unsigned long full_length = [self length];
    unsigned long half_length = [self length] / 2;
    
    NSMutableData *gunzippedData = [NSMutableData dataWithLength: full_length + half_length];
    
   // NSMutableData* gunzippedData = [NSMutableData dataWithLength:nUncompressedBytes];
    
    zStream.next_in = (Bytef*)self.bytes;
    zStream.avail_in = (unsigned int)self.length;
    zStream.next_out = (Bytef*)gunzippedData.bytes;
    zStream.avail_out = (unsigned int)gunzippedData.length;
    
    iResult = inflate(&zStream, Z_FINISH);
    if(iResult != Z_STREAM_END)
    {
        if(error)
            *error = [NSError errorWithDomain:BBZlibErrorDomain code:iResult userInfo:nil];
        gunzippedData = nil;
    }
    inflateEnd(&zStream);
    return gunzippedData;
}

@end
