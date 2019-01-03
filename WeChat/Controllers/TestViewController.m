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
//    request.mobile = @"+8618631506453";
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
//    [WeChatClient postRequest:cgiWrap success:^(BindOpMobileResponse *  _Nullable response) {
//        LogVerbose(@"%@", response);
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
    
    NSData *data = [NSData dataWithHexString:@"0ACC03089DFDFFFFFFFFFFFFFF0112BE030ABB033C653E0A3C53686F77547970653E383C2F53686F77547970653E0A3C436F6E74656E743E3C215B43444154415B5D5D3E3C2F436F6E74656E743E0A3C55726C3E3C215B43444154415B68747470733A2F2F77656978696E3131302E71712E636F6D2F73656375726974792F7265616474656D706C6174653F743D7369676E75705F7665726966792F775F696E74726F2672656763633D3836267265676D6F62696C653D31343130303030313038302672656769643D335F3136323931353632333631363631373033383636267363656E653D6765745F7265675F7665726966795F636F6465267765636861745F7265616C5F6C616E673D7A685F434E5D5D3E3C2F55726C3E0A3C446973705365633E303C2F446973705365633E0A3C5469746C653E3C215B43444154415B5D5D3E3C2F5469746C653E0A3C416374696F6E3E303C2F416374696F6E3E0A3C44656C6179436F6E6E5365633E303C2F44656C6179436F6E6E5365633E0A3C436F756E74646F776E3E303C2F436F756E74646F776E3E0A3C4F6B3E3C215B43444154415B5D5D3E3C2F4F6B3E0A3C43616E63656C3E3C215B43444154415B5D5D3E3C2F43616E63656C3E0A3C2F653E0A20003A02080042060800100028004A081800200028003800580062032B38366800720208007A0B31343130303030313038308201112B383620313431203030303020313038308A019A03080912050801120133120608041202363012050805120131120508061201311205080712013012050808120130120508091201301205080A12013012DC02081112D7023C776F7264696E673E3C7377697463683E313C2F7377697463683E3C7469746C653EE69FA5E689BEE4BDA0E79A84E5BEAEE4BFA1E69C8BE58F8B3C2F7469746C653E3C646573633EE5BEAEE4BFA1E5B086E4B88AE4BCA0E6898BE69CBAE9809AE8AEAFE5BD95E887B3E5BEAEE4BFA1E69C8DE58AA1E599A8E4BBA5E58CB9E9858DE58F8AE68EA8E88D90E69C8BE58F8BE380820A28E4B88AE4BCA0E9809AE8AEAFE5BD95E4BB85E794A8E4BA8EE58CB9E9858DEFBC8CE4B88DE4BC9AE4BF9DE5AD98E8B584E69699EFBC8CE4BAA6E4B88DE4BC9AE794A8E4BD9CE5AE83E794A8293C2F646573633E3C696F736578646573633EE5BEAEE4BFA1E4BB85E4BDBFE794A8E789B9E5BE81E7A081E794A8E688B7E58CB9E9858DE8AF86E588ABEFBC8CE4B88DE4BC9AE4BF9DE5AD98E4BDA0E79A84E9809AE8AEAFE5BD95E58685E5AEB93C2F696F736578646573633E3C2F776F7264696E673E900101A80100B20116335F3136323931353632333631363631373033383636"];
    
    NSError *error = nil;
    BindOpMobileResponse *resp = [[BindOpMobileResponse alloc] initWithData:data error:&error];
    if (error) {
        LogVerbose(@"%@", error);
    } else {
        LogVerbose(@"%@", resp);
    }
}

@end

