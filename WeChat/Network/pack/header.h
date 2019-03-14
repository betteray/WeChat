//
//  header.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, EncryptMethod) {
    NONE = 0x1,
    AES = 0x5,
    RSA = 0x7,
    AUTOAUTH = 0x9,
};

@interface header : NSObject

+ (NSData *)make_header:(int)cgi
          encryptMethod:(EncryptMethod)encryptMethod
               bodyData:(NSData *)bodyData
     compressedBodyData:(NSData *)compressedBodyData
             needCookie:(BOOL)needCookie
                 cookie:(NSData *)cookie
                    uin:(uint32_t)uin;

+ (NSData *)make_header2:(int)cgi
           encryptMethod:(EncryptMethod)encryptMethod
                bodyData:(NSData *)bodyData
      compressedBodyData:(NSData *)compressedBodyData
              needCookie:(BOOL)needCookie
                  cookie:(NSData *)cookie
                     uin:(uint32_t)uin;

+ (NSData *)make_header3:(int)cgi
           encryptMethod:(EncryptMethod)encryptMethod
                bodyData:(NSData *)bodyData
      compressedBodyData:(NSData *)compressedBodyData
              needCookie:(BOOL)needCookie
                  cookie:(NSData *)cookie
                     uin:(uint32_t)uin;

@end
