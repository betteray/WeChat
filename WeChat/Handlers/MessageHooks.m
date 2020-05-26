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
#import "PasswordService.h"
#import "CheckResUpdateServices.h"

@implementation MessageHooks

+ (void)handleMsg:(NSString *) msg {
    if ([msg isEqualToString:@"querymid"]) {
        LogVerbose(@"querymid get test......");
        [QueryMidService startRequest];
    } else if ([msg isEqualToString:@"fpfreshnl"]) {
        LogVerbose(@"fpfreshnl get test......");
        [FPService fpfresh:YES];
    } else if ([msg isEqualToString:@"changepassword"]) {
        LogVerbose(@"changepassword get test......");
        [PasswordService NewverifyPasswd:@"xiao@12345" newPassword:@"xiao@123"];
    } else if([msg isEqualToString:@"checkresupdate"]) {
        LogVerbose(@"checkresupdate get test......");
        [CheckResUpdateServices checkUpdate];
    }
}

@end
