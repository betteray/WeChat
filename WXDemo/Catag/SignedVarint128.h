#import <Foundation/Foundation.h>

@interface SignedVarint128 : NSObject

+ (NSData *)dataWithInt:(int)value;
+ (NSData *)dataWithSInt32:(SInt32)value;
+ (NSData *)dataWithSInt64:(SInt64)value;

+ (SInt32)decode32FromBytes:(const void *)bytes offset:(UInt32 *)offset;
+ (SInt64)decode64FromBytes:(const void *)bytes offset:(UInt32 *)offset;

@end
