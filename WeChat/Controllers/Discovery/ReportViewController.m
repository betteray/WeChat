//
//  ReportViewController.m
//  WeChat
//
//  Created by ysh on 2019/7/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ReportViewController.h"
#import "GetkvidkeyStrategyService.h"
#import <sys/time.h>

@interface ReportViewController ()

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startReport:(id)sender {
//    [GetkvidkeyStrategyService get];
    
    NSData *data = [NSData dataWithHexString:@"10021A040800120022020A002A020A0032020A003A92010A8F0168747470733A2F2F737570706F72742E77656978696E2E71712E636F6D2F6367692D62696E2F6D6D737570706F72742D62696E2F61646463686174726F6F6D6279696E766974653F7469636B65743D4133595A44797A7A3852577931387A7667636E6A4F772533442533442666726F6D3D73696E676C656D657373616765266973617070696E7374616C6C65643D3050015A13777869645F70793270737532716C797666323262006A00700078648A010457494649A00194DDB2F307AA0100B00100"];
    NSError *error = nil;
    GetA8KeyReq *req = [[GetA8KeyReq alloc] initWithData:data error:&error];
    SKBuiltinString_t *str = [SKBuiltinString_t new];
    str.string = @"https://support.weixin.qq.com/cgi-bin/mmsupport-bin/addchatroombyinvite?ticket=A7J4dj8MbCs%2BUvaoRfIGJw%3D%3D";
    req.reqURL = str;
    
    struct timeval tv;
    gettimeofday(&tv, NULL);
    uint32_t requestId = (unsigned int)(274877907LL * tv.tv_usec >> 38)
    + ((uint64_t)(274877907LL * tv.tv_usec) >> 63)
    + 1000 * (tv.tv_sec);
    
    req.requestId = requestId;
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 233;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/geta8key";
    cgiWrap.request = req;
    cgiWrap.responseClass = [GetA8KeyResp class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(GetA8KeyResp * _Nullable response) {
        LogVerbose(@"%@", response);
        
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:response.fullURL]];
        req.HTTPMethod = @"POST";
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            LogVerbose(@"%@", response);
        }];
        [task resume];
        
        //        if (response.baseResponse.ret == 0) {
        //            UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
        //            MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
        //            webViewController.url = [NSURL URLWithString:response.fullURL];
        //            [self.navigationController pushViewController:webViewController animated:YES];
        //        }
        
    } failure:^(NSError * _Nonnull error) {
        LogError(@"%@", error);
    }];
}

@end
