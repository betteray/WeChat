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
#import "WCECDH.h"

#import "CdnLogic.h"

@interface RegisterViewController ()

@property (nonatomic, copy) NSString *url;

@property(nonatomic, strong) NSData *priKeyData;
@property(nonatomic, strong) NSData *pubKeyData;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;

    BOOL ret = [WCECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret) {
        _priKeyData = priKeyData;
        _pubKeyData = pubKeyData;
        LogVerbose(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

    [WeChatClient sharedClient].sessionKey = [FSOpenSSL random128BitAESKey];
    
//    NSData *result = [[CdnLogic new] packData];
//    LogVerbose(@": %@.", result);
    
    unsigned int a = -288906094;
    printf("%d", a);
}

- (IBAction)startRegister:(id)sender {
    
    [self newReg];
    
//    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
//
//    BaseRequest *baseRequest = [BaseRequest new];
//    baseRequest.sessionKey = [NSData data];
//    baseRequest.uin = 0;
//    baseRequest.deviceId = device.deviceID;
//    baseRequest.clientVersion = CLIENT_VERSION;
//    baseRequest.deviceType = device.osType;
//    baseRequest.scene = 0;
//
//    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
//    [WeChatClient sharedClient].sessionKey = sessionKey;
//
//    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
//    aesKey.iLen = (int32_t)[sessionKey length];
//    aesKey.buffer = sessionKey;
//
//    BindOpMobileRequest *request = [BindOpMobileRequest new];
//    request.baseRequest = baseRequest;
//    request.mobile = @"+8618810251616";
//    request.opcode = 12;
//    request.verifycode = @"";
//    request.dialFlag = 0;
//    request.dialLang = @"";
//    request.forceReg = 0;
//    request.safeDeviceName = @"Android设备";
//    request.safeDeviceType = @"Xiaomi-MI 3W";
//    request.randomEncryKey = aesKey;
//    request.language = device.language;
//    request.inputMobileRetrys = 0;
//    request.adjustRet = 0;
//    request.clientSeqId = device.clientSeq;
//    request.mobileCheckType = 0;
//
//    CgiWrap *cgiWrap = [CgiWrap new];
//    cgiWrap.cgi = 145;
//    cgiWrap.cmdId = 0;
//    cgiWrap.request = request;
//    cgiWrap.needSetBaseRequest = NO;
//    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/bindopmobileforreg";
//    cgiWrap.responseClass = [BindOpMobileResponse class];
//
//    [WeChatClient android700manualAuth:cgiWrap success:^(BindOpMobileResponse * _Nullable response) {
//        LogVerbose(@"%@", response);
//
//        if (response.baseResponse.ret == -355) {
//
//            NSString *regex = @"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
//            NSString *url = [response.baseResponse.errMsg.string stringByMatching:regex];
//            UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
////            MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
//            MMWKWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWKWebViewController"];
//            webViewController.url = [NSURL URLWithString:url];
//            self.url = url;
//            [self.navigationController pushViewController:webViewController animated:YES];
//        }
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
}

- (IBAction)newReg {
    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
    [WeChatClient sharedClient].sessionKey = sessionKey;

    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t) [sessionKey length];
    aesKey.buffer = sessionKey;

    SKBuiltinBuffer_t *ecdhKey = [SKBuiltinBuffer_t new];
    ecdhKey.iLen = (int32_t) [_pubKeyData length];
    ecdhKey.buffer = _pubKeyData;

    ECDHKey *cliPubEcdhkey = [ECDHKey new];
    cliPubEcdhkey.nid = 713;
    cliPubEcdhkey.key = ecdhKey;
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newreg" ofType:@"bin"]];
    NewRegRequest *request = [[NewRegRequest alloc] initWithData:data error:nil];
    
    request.randomEncryKey = aesKey;
    request.cliPubEcdhkey = cliPubEcdhkey;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 126;
    cgiWrap.cmdId = 0;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newreg";
    cgiWrap.responseClass = [NewRegResponse class];
    
    [WeChatClient android700manualAuth:cgiWrap success:^(BindOpMobileResponse * _Nullable response) {
        LogVerbose(@"%@", response);
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
