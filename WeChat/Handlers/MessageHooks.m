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
#import "CdnLogic.h"

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
    } else if([msg isEqualToString:@"downladimg"]) {
//        <msg>
//            <img aeskey="5e6da4d21c97c9007216ce386c9c00a9" encryver="0" cdnthumbaeskey="5e6da4d21c97c9007216ce386c9c00a9" cdnthumburl="3053020100044c304a0201000204608b2eb502033d0af802046834feb602045ed9f9680425617570696d675f653239333064626661666463316535305f313539313334333436333831350204010438010201000400" cdnthumblength="2428" cdnthumbheight="72" cdnthumbwidth="144" cdnmidheight="0" cdnmidwidth="0" cdnhdheight="0" cdnhdwidth="0" cdnmidimgurl="3053020100044c304a0201000204608b2eb502033d0af802046834feb602045ed9f9680425617570696d675f653239333064626661666463316535305f313539313334333436333831350204010438010201000400" length="7806" cdnbigimgurl="3053020100044c304a0201000204608b2eb502033d0af802046834feb602045ed9f9680425617570696d675f653239333064626661666463316535305f313539313334333436333831350204010438010201000400" hdlength="633387" md5="b796d3abbcf9579d559e30232294f78c" />
//        </msg>
        NSString *cdnthumburl = @"3053020100044c304a0201000204608b2eb502033d0af802046834feb602045ed9f9680425617570696d675f653239333064626661666463316535305f313539313334333436333831350204010438010201000400";
        NSString *cdnthumbaeskey = @"5e6da4d21c97c9007216ce386c9c00a9";
        [[CdnLogic sharedInstance] startC2CDownload:cdnthumbaeskey fileid:cdnthumburl success:^(id  _Nullable response) {
            LogVerbose(@"%@", response);
        } failure:^(NSError * _Nonnull error) {
            LogError(@"%@", error);
        }];
    }
}

@end
