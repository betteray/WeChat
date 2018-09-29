#import <Foundation/Foundation.h>

@interface Varint128 : NSObject

+ (NSData *)dataWithUnsignedInt:(unsigned int)value;
+ (NSData *)dataWithUInt32:(UInt32)value;
+ (NSData *)dataWithUInt64:(UInt64)value;

+ (UInt32)decode32FromBytes:(const void *)bytes offset:(UInt32 *)offset;
+ (UInt64)decode64FromBytes:(const void *)bytes offset:(UInt32 *)offset;

@end
