//
//  SnsTimeLineViewController.m
//  WeChat
//
//  Created by ray on 2018/12/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "SnsTimeLineViewController.h"

@interface SnsTimeLineViewController ()

@end

@implementation SnsTimeLineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)fetchSnsTimeLine:(id)sender
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
                          LogInfo(@"SnsTimeLine Resp: %@", response);
                      }
                      failure:^(NSError *_Nonnull error){

                      }];
}

@end
