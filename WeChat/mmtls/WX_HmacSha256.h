//
//  WX_HmacSha256.h
//  WXDemo
//
//  Created by ray on 2018/11/11.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WX_HmacSha256 : NSObject

+ (unsigned char*) HmacSha256WithKey:(NSData *)key data:(NSData *)data result:(NSData **)result;

@end
