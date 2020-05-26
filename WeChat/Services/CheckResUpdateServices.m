//
//  CheckResUpdateServices.m
//  WeChat
//
//  Created by ray on 2020/5/26.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CheckResUpdateServices.h"

@implementation CheckResUpdateServices

+ (void)checkUpdate {
    CheckResUpdateRequest *request = [CheckResUpdateRequest new];
    request.scene = 0;
    request.context = [NSData data];
    
    NSMutableArray *ma = [NSMutableArray array];
    for (int i=0; i<100; i++) {
        ResourceTypeReq *req = [ResourceTypeReq new];
        req.type = i;
        req.subTypeVectorArray = [NSMutableArray array];
        [ma addObject:req];
    }
    
    request.resIdArray = ma;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 721;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/checkresupdate";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckResUpdateResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(CheckResUpdateResponse *  _Nullable response) {
        if (response.baseResponse.ret == 0) {
            LogVerbose(@"checkresupdate Suc: %@", response);

        } else {
            LogVerbose(@"checkresupdate failed!!!");
        }
    } failure:^(NSError * _Nonnull error) {
        LogVerbose(@"checkresupdate failed: %@", error);
    }];
}

@end
