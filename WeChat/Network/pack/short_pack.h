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

+ (ShortPackage *)unpack:(NSData *)body;

@end
