#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ENC : NSObject

 +(int)nativewcswbaes:(char* )library,
                   char *srcbuffer, unsigned int srcbuffersize,
                   char *iv, unsigned int ivsize,
                   char *saedattablekey, unsigned int saedattablekeylen,
                   char *saedattablevalue, unsigned int saedattablevaluelen,
                   char *saetablefinal, unsigned int saetablefinallen,
                   unsigned int encodetype,
                   char *outbuffer, unsigned int *outbufferlen;

int makeKeyHash(int key);

@end

NS_ASSUME_NONNULL_END
