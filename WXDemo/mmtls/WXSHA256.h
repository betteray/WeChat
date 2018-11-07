//
//  SHA256.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXSHA256 : NSObject

+ (NSData *)wx_sha256:(char *)buf;

@end
