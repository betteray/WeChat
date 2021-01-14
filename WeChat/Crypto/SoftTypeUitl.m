//
//  SoftTypeUitl.m
//  WeChat
//
//  Created by ray on 2020/6/5.
//  Copyright © 2020 ray. All rights reserved.
//

#import "SoftTypeUitl.h"

static unsigned int uin = 2263357049;

@implementation SoftTypeUitl

+ (void)calculateK25 {
    NSData *data = [NSData dataWithHexString:@"3f1cacfadf3f75ec4629692a119c02b5"]; // k25 结果
   
    NSMutableData *r = [NSMutableData data];
    
    for (int i=0; i<4; i++) {
        unsigned int i1 = 0;
        [data getBytes:&i1 range:NSMakeRange(i * 4, 4)];
        
        unsigned int result = i1 ^ uin;
        
        NSData *d = [NSData dataWithBytes:&result length:4];
        [r appendData:d];
    }
    
    LogVerbose(@"%@", r);
}

+ (void)calculateK289 {
    NSData *data = [NSData dataWithHexString:@"9bdfa98f edbf6109"]; // k28 k29四字节
   
    NSMutableData *r = [NSMutableData data];
    
    for (int i=0; i<2; i++) {
        unsigned int i1 = 0;
        [data getBytes:&i1 range:NSMakeRange(i * 4, 4)];
        
        unsigned int result = ntohl(i1) ^ uin;
        
        NSData *d = [NSData dataWithBytes:&result length:4];
        [r appendData:d];
    }
    
    LogVerbose(@"%@", r);
}

@end
