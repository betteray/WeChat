//
//  NewInitViewController.m
//  WeChat
//
//  Created by ray on 2018/12/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "TestViewController.h"
#import "FSOpenSSL.h"
#import "SyncKeyCompare.h"

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
- (IBAction)registerr:(id)sender {
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

- (IBAction)register:(id)sender
{
    SyncKey *resp = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12080802 10a2f9d6 9e021208 080310cd f6d69e02 12040804 10001204 08051000 12040807 10001208 080810a3 f8d69e02 12080809 10b0f7d6 9e021204 080a1000 1208080b 10fde6d6 9e021208 080d10f1 dcd59e02 1208080e 10f1dcd5 9e021208 081010f1 dcd59e02 12080811 10f1dcd5 9e021204 08651000 12040866 10001204 08671000 12040868 10001204 08691000 1204086b 10001204 086d1000 1204086f 10001204 08701000 12040872 10001209 08c90110 f3f3cae1 05120508 cb011000 120508cc 01100012 0508cd01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];
    
    SyncKey *req = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12040865 10001208 080210be f9d69e02 12040866 10001208 080d10f1 dcd59e02 120508cc 01100012 08080310 cdf6d69e 02120408 67100012 08080b10 fde6d69e 02120408 6f100012 04080410 00120408 68100012 04080510 00120408 69100012 04080710 00120408 6b100012 08080810 a3f8d69e 02120808 0910b0f7 d69e0212 08081010 f1dcd59e 02120808 1110f1dc d59e0212 04087210 00120808 0e10f1dc d59e0212 04087010 00120408 6d100012 04080a10 00120908 c90110fc 88cce105 120508cd 01100012 0508cb01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];
    
    [SyncKeyCompare compaireOldSyncKey:resp newSyncKey:req];
}

@end

