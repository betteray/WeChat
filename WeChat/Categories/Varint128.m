#import "Varint128.h"
//#import <Protobuf/GPBCodedOutputStream_PackagePrivate.h>

@implementation Varint128

//size_t size = GPBComputeRawVarint32Size(0xf8a9a1cc);
//NSMutableData *md = [NSMutableData dataWithLength:size];
//GPBCodedOutputStream *outputStream = [[GPBCodedOutputStream alloc] initWithData:md];
//[outputStream writeUInt32NoTag:0xf8a9a1cc];

+ (NSData *)dataWithUnsignedInt:(unsigned int)value
{
    return [self dataWithUInt32:value];
}

+ (NSData *)dataWithUInt32:(UInt32)x
{
    uint8_t bytes[5];
    int i = 0;
    bytes[0] = 0;
    while (x > 0)
    {
        bytes[i] = (x & 0x7F);
        x = x >> 7;
        if (x > 0)
        {
            bytes[i] = bytes[i] | 0x80;
            i++;
        }
    }
    i++;
    return [NSData dataWithBytes:bytes length:i];
}

+ (NSData *)dataWithUInt64:(UInt64)x
{
    uint8_t bytes[10];
    int i = 0;
    bytes[0] = 0;
    while (x > 0)
    {
        bytes[i] = (x & 0x7F);
        x = x >> 7;
        if (x > 0)
        {
            bytes[i] = bytes[i] | 0x80;
            i++;
        }
    }
    i++;
    return [NSData dataWithBytes:bytes length:i];
}

+ (UInt32)decode32FromBytes:(const void *)bytes offset:(UInt32 *)offsetPointer
{
    UInt8 *octets = (UInt8 *) bytes;
    UInt32 offset = *offsetPointer;
    UInt32 result = 0;
    int shift = 0;
    while (YES)
    {
        result += ((octets[offset] & 0x7F) << shift);
        if (octets[offset] < 128)
        {
            *offsetPointer = offset + 1;
            return result;
        }
        offset++;
        shift += 7;
    }
}

+ (UInt64)decode64FromBytes:(const void *)bytes offset:(UInt32 *)offsetPointer
{
    UInt8 *octets = (UInt8 *) bytes;
    UInt32 offset = *offsetPointer;
    UInt64 result = 0;
    int shift = 0;
    while (YES)
    {
        result += (((UInt64) octets[offset] & 0x7F) << shift);
        if (octets[offset] < 128)
        {
            *offsetPointer = offset + 1;
            return result;
        }
        offset++;
        shift += 7;
    }
}

@end
