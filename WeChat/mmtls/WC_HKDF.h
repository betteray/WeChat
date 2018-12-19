//
//  HKDF.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WC_HKDF : NSObject

+ (NSData *)HKDF_Expand:(NSData *)prk Info:(NSData *)info;
+ (NSData *)HKDF_Expand_Prk2:(NSData *)prk Info:(NSData *)info;
+ (void)HKDF_Expand_Prk3:(NSData *)prk Info:(NSData *)info outOkm:(NSData **)outOkm;

@end
