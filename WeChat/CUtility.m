//
//  CUtility.m
//  WeChat
//
//  Created by ysh on 2019/1/12.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CUtility.h"

@implementation CUtility

+ (uint32_t)numberVersionOf:(NSString *)stringVersion
{
    NSArray *components = [stringVersion componentsSeparatedByString:@"."];
    
    NSParameterAssert([components count]==4);
    
    NSInteger majorVersion = [components[0] integerValue];
    NSInteger minorVersion = [components[1] integerValue];
    NSInteger patchVersion = [components[2] integerValue];
    NSInteger buildVersion = [components[3] integerValue];
    
    return (uint32_t) ((majorVersion << 24) | (minorVersion << 16) | (patchVersion << 8) | buildVersion | 0x10000000);
}

@end
