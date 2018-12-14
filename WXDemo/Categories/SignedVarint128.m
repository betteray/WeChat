#import "SignedVarint128.h"
#import "Varint128.h"

@implementation SignedVarint128

+ (NSData *)dataWithInt:(int)value {
    return [self dataWithSInt32:value];
}

+ (NSData *)dataWithSInt32:(SInt32)value {
    UInt32 encoded = (UInt32)((value << 1) ^ (value >> 31));
    return [Varint128 dataWithUInt32:encoded];
}

+ (NSData *)dataWithSInt64:(SInt64)value {
    UInt64 encoded = (UInt64)((value << 1) ^ (value >> 63));
    return [Varint128 dataWithUInt64:encoded];
}

+ (SInt32)decode32FromBytes:(const void *)bytes offset:(UInt32 *)offset {
    UInt32 n = [Varint128 decode32FromBytes:bytes offset:offset];
    return (n >> 1) ^ -(n & 1);
}

+ (SInt64)decode64FromBytes:(const void *)bytes offset:(UInt32 *)offset {
    UInt64 n = [Varint128 decode64FromBytes:bytes offset:offset];
    return (n >> 1) ^ -(n & 1);
}

@end
