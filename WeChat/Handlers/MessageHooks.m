//
//  MessageHooks.m
//  WeChat
//
//  Created by ray on 2020/5/19.
//  Copyright © 2020 ray. All rights reserved.
//

#import "MessageHooks.h"
#import "QueryMidService.h"
#import "FPService.h"

@implementation MessageHooks

+ (void)handleMsg:(NSString *) msg {
    if ([msg isEqualToString:@"querymid"]) {
        LogVerbose(@"querymid get test......");
        [QueryMidService startRequest];
    } else if ([msg isEqualToString:@"fpfreshnl"]) {
        LogVerbose(@"fpfreshnl get test......");
        [FPService fpfresh];
    }
}

@end
