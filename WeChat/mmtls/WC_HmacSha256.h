//
//  WX_HmacSha256.h
//  WXDemo
//
//  Created by ray on 2018/11/11.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WC_HmacSha256 : NSObject

+ (NSData *)HmacSha256WithKey:(NSData *)key data:(NSData *)data;

@end
