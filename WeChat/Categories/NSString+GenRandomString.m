//
//  NSString+GenRandomString.m
//  WXDemo
//
//  Created by ray on 2018/9/21.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSString+GenRandomString.h"

const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation NSString (GenRandomString)

+ (instancetype)GenRandomStringWithSize: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int32_t)[letters length])]];
    }
    
    return randomString;
}

@end
