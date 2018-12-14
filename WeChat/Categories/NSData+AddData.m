//
//  NSData+AddData.m
//  WXDemo
//
//  Created by ray on 2018/11/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSData+AddData.h"

@implementation NSData (AddData)

- (NSData *)addDataAtTail:(NSData *)data {
    NSMutableData *ma = [NSMutableData dataWithCapacity:[self length] + [data length]];
    [ma appendData:self];
    [ma appendData:data];
    
    return [ma copy];
}

- (NSData *)addDataAtHead:(NSData *)data {
    NSMutableData *ma = [NSMutableData dataWithCapacity:[data length] + [self length]];
    [ma appendData:data];
    [ma appendData:self];
    
    return [ma copy];
}

@end
