//
//  mmpack.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShortPackage;

@interface mmpack : NSObject

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

+ (ShortPackage *)DecodePack:(NSData *)body;

@end
