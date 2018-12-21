//
//  NewInitViewController.m
//  WeChat
//
//  Created by ray on 2018/12/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)Test:(id)sender
{
    CheckResUpdateRequest_ResID_SubTypeVector *crs = [CheckResUpdateRequest_ResID_SubTypeVector new];
    crs.subType = 1;
    crs.keyVersion = 0;
    crs.resVersion = 473;
    crs.eid = 0;

    CheckResUpdateRequest_ResID *resID = [CheckResUpdateRequest_ResID new];
    resID.type = 37;
    resID.subTypeVectorArray = [@[crs] mutableCopy];

    CheckResUpdateRequest *request = [[CheckResUpdateRequest alloc] init];
    request.resIdArray = [@[resID] mutableCopy];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 180;
    cgiWrap.cmdId = 0;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/encryptchecktinkerupdate";
//    cgiWrap.responseClass = [GetLoginQRCodeResponse class];
    
    [WeChatClient postRequest:cgiWrap success:^(id  _Nullable response) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end

