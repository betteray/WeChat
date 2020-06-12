//
//  CUtility.m
//  WeChat
//
//  Created by ysh on 2019/1/12.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CUtility.h"
#import "FSOpenSSL.h"
#include <sys/time.h>

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

+ (NSString *)StringVersionOf:(long)numberVersion {
    NSString *buildVersion = [@(numberVersion & 0xFF) stringValue];
    NSString *patchVersion = [@((numberVersion & 0xFF00) >> 8) stringValue];
    NSString *minorVersion = [@((numberVersion & 0xFF0000) >> 16) stringValue];
    NSString *majorVersion = [@((numberVersion & 0xF000000) >> 24) stringValue];
    
    return [NSString stringWithFormat:@"%@.%@.%@.%@", majorVersion, minorVersion, patchVersion, buildVersion];
}

+ (NSString *)GetUUIDNew
{
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuidString = [uuid UUIDString];
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [FSOpenSSL md5StringFromString:uuidString];
}

+ (NSString *)GetDeviceID
{
    NSString *uuidNew = [self GetUUIDNew];
    return [uuidNew stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"49"];
}

+ (NSInteger)GetTimeStampInSecond {
    struct timeval tp = {0};
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    return tp.tv_sec;
}

+ (NSInteger)GetTimeInMilliSecond {
    struct timeval tv = {0};
    if (gettimeofday(&tv, NULL) != 0) LogVerbose(@"Error get time");
    return (int64_t) tv.tv_sec*1000 + tv.tv_usec/1000;
}

@end
