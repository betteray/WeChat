//
//  NewInitViewController.m
//  WeChat
//
//  Created by ray on 2018/12/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "TestViewController.h"
#import "FSOpenSSL.h"

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
- (IBAction)register:(id)sender {
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
    request.mobile = @"+8618631506453";
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
    
    [WeChatClient postRequest:cgiWrap success:^(BindOpMobileResponse *  _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {
        
    }];

}

@end

