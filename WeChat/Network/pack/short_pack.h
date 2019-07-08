//
//  short_pack.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShortPackage;

@interface short_pack : NSObject

+ (NSData *)pack:(int)cgi
   serilizedData:(NSData *)serilizedData
            type:(NSInteger)type
             uin:(uint32_t)uin
          cookie:(NSData *)cookie;

+ (NSData *)EncodeHybirdEcdhEncryptPack:(int)cgi
                          serilizedData:(NSData *)serilizedData
                                    uin:(uint32_t)uin
                                 cookie:(NSData *)cookie
                             rsaVersion:(int)rsaVersion;

+ (NSData *)EncodePack:(int)cgi
         serilizedData:(NSData *)serilizedData
                   uin:(uint32_t)uin
                aesKey:(NSData *)aesKey
                cookie:(NSData *)cookie
             signature:(int)signature;

+ (ShortPackage *)unpack:(NSData *)body;

@end
