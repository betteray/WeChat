//
//  NSString+Concat.m
//  WXDemo
//
//  Created by ray on 2018/11/28.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSString+Concat.h"

@implementation NSString (Concat)

+ (instancetype) append:(id) first, ...
{
    NSString * result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
        result = [result stringByAppendingString:first];
        va_start(alist, first);
        while ((eachArg = va_arg(alist, id)))
            result = [result stringByAppendingString:eachArg];
        va_end(alist);
    }
    return result;
}

@end
