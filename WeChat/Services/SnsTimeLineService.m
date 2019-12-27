//
//  SnsService.m
//  WeChat
//
//  Created by ray on 2019/12/27.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SnsTimeLineService.h"

@implementation SnsTimeLineService

+ (void)fetchSnsTimeLine
{
    SnsTimeLineRequest *request = [SnsTimeLineRequest new];
    request.firstPageMd5 = @"";
    request.minFilterId = 0;
    request.maxId = 0;
    request.lastRequestTime = 0;
    request.clientLatestId = 0;
    request.networkType = 1;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 211;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/mmsnstimeline";
    cgiWrap.responseClass = [SnsTimeLineResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(SnsTimeLineResponse *_Nullable response) {
                          LogVerbose(@"SnsTimeLine Resp: %@", response);
                      }
                      failure:^(NSError *_Nonnull error){
                          
                      }];
}

@end
