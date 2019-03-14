//
//  RegisterViewController.m
//  WeChat
//
//  Created by ysh on 2019/2/12.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RegisterViewController.h"
#import "FSOpenSSL.h"
#import "MMWebViewController.h"
#import "MMWKWebViewController.h"
#import <RegexKitLite/RegexKitLite.h>

@interface RegisterViewController ()

@property (nonatomic, copy) NSString *url;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startRegister:(id)sender {
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    
    BaseRequest *baseRequest = [BaseRequest new];
    baseRequest.sessionKey = [NSData data];
    baseRequest.uin = 0;
    baseRequest.deviceId = device.deviceID;
    baseRequest.clientVersion = CLIENT_VERSION;
    baseRequest.deviceType = device.osType;
    baseRequest.scene = 0;
    
    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
    [WeChatClient sharedClient].sessionKey = sessionKey;
    
    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t)[sessionKey length];
    aesKey.buffer = sessionKey;
    
    BindOpMobileRequest *request = [BindOpMobileRequest new];
    request.baseRequest = baseRequest;
    request.mobile = @"+8618631506451";
    request.opcode = 12;
    request.verifycode = @"";
    request.dialFlag = 0;
    request.dialLang = @"";
    request.forceReg = 0;
    request.safeDeviceName = @"Android设备";
    request.safeDeviceType = @"Xiaomi-MI 3W";
    request.randomEncryKey = aesKey;
    request.language = device.language;
    request.inputMobileRetrys = 0;
    request.adjustRet = 0;
    request.clientSeqId = device.clientSeq;
    request.mobileCheckType = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 145;
    cgiWrap.cmdId = 0;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/bindopmobileforreg";
    cgiWrap.responseClass = [BindOpMobileResponse class];
    
    [[WeChatClient sharedClient] registerWeChat:cgiWrap success:^(BindOpMobileResponse * _Nullable response) {
        LogVerbose(@"%@", response);
        
        if (response.baseResponse.ret == -355) {
            
            NSString *regex = @"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
            NSString *url = [response.baseResponse.errMsg.string stringByMatching:regex];
            UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
//            MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
            MMWKWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWKWebViewController"];
            webViewController.url = [NSURL URLWithString:url];
            self.url = url;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)reload:(id)sender {
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
    webViewController.url = [NSURL URLWithString:_url];
    [self.navigationController pushViewController:webViewController animated:YES];
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
