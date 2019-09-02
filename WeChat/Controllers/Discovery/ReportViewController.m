//
//  ReportViewController.m
//  WeChat
//
//  Created by ysh on 2019/7/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ReportViewController.h"
#import "Business.h"

#import "Mmkv.pbobjc.h"

@interface ReportViewController ()

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startReport:(id)sender {
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newreportkvcomm" ofType:@"bin"]];
//    CliReportKVReq *req = [[CliReportKVReq alloc] initWithData:data error:nil];
//
//    CgiWrap *cgiWrap = [CgiWrap new];
//    cgiWrap.cgi = 997;
//    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newreportkvcomm";
//    cgiWrap.request = req;
//    cgiWrap.responseClass = [CliReportKVResp class];
//    cgiWrap.needSetBaseRequest = NO;
//

    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1564458117_getexptconfig_2738_GetExptRequest" ofType:@"bin"]];
    GetExptRequest *req = [[GetExptRequest alloc] initWithData:data error:nil];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 2738;
    cgiWrap.cgiPath = @"/cgi-bin/mmexptappsvr-bin/getexptconfig";
    cgiWrap.request = req;
    cgiWrap.responseClass = [GetExptResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(CliReportKVResp * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {

    }];


//    [Business newSync];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
