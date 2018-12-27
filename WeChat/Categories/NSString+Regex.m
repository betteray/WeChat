//
//  NSString+Regex.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSString+Regex.h"
#import "RegexKitLite.h"

@implementation NSString (Regex)

- (BOOL)isValidIP
{
    NSString *ipRegexString = @"(2(5[0-5]{1}|[0-4]\\d{1})|[0-1]?\\d{1,2})(\\.(2(5[0-5]{1}|[0-4]\\d{1})|[0-1]?\\d{1,2})){3}";
    return [self isMatchedByRegex:ipRegexString];
}


@end
