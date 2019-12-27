//
//  GetkvidkeyStrategyService.m
//  WeChat
//
//  Created by ray on 2019/12/26.
//  Copyright © 2019 ray. All rights reserved.
//

#import "GetkvidkeyStrategyService.h"

@implementation GetkvidkeyStrategyService

+ (void)get {
    GetCliKVStrategyReq *request = [GetCliKVStrategyReq new];
    request.kvspecialVersion = 0;
    request.randomEncryKey = [NSData data];
    request.generalVersion = 1576668309;
    
    HeavyUserReqInfo *reqInfo = [HeavyUserReqInfo new];
    reqInfo.monitorIdMapVersion = 1528189577;
    
    request.heavyUserInfo = reqInfo;
    request.whiteOrBlackUinVersion = 0;
    request.kvgeneralVersion = 41;
    request.kvwhiteOrBlackUinVersion = 3;
    request.specialVersion = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 988;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/getkvidkeystrategy";
    cgiWrap.request = request;
    cgiWrap.responseClass = [GetCliKVStrategyResp class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(GetCliKVStrategyResp * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

@end
