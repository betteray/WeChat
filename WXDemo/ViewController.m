//
//  ViewController.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ViewController.h"
#import "WeChatClient.h"
#import "Mm.pbobjc.h"
#import "Constants.h"
#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "CgiWrap.h"
#import "NSData+PackUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECDH.h"

#define TICK_INTERVAL 1.5

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;

@property (nonatomic, strong) NSData *nofityKey;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)getQRCode {
    NSLog(@"扫描成功");
    [self.qrcodeCheckTimer invalidate];
    self.qrcodeCheckTimer = nil;
    
    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:16];
    [buffer setBuffer:[WeChatClient sharedClient].clientAesKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:0];
    [request setUserName:nil];
    [request setSoftType:nil];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 502;
    cgiWrap.cmdId = 232;
    cgiWrap.request = request;
    cgiWrap.responseClass = [GetLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        NSLog(@"%@", response);
        GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *)response;
        
        if (resp) {
            self.nofityKey = resp.notifyKey.buffer;
            self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
            self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
            self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tick:(NSTimer *)timer {
    [self updateUI];
    
    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];
    
    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:16];
    [buffer setBuffer:[WeChatClient sharedClient].clientAesKey];
    [request setRandomEncryKey:buffer];

    request.uuid = ((GetLoginQRCodeResponse *)[timer userInfo]).uuid;
    request.timeStamp = [[NSDate date] timeIntervalSince1970];
    request.opcode = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 503;
    cgiWrap.cmdId = 233;
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        CheckLoginQRCodeResponse *resp = (CheckLoginQRCodeResponse *)response;
        if (resp.base.code == 0) {
            NSData *notifyProtobufData = [[resp.notifyPkg.notifyData buffer] aesDecryptWithKey:self.nofityKey];
            NotifyMsg *msg = [NotifyMsg parseFromData:notifyProtobufData error:nil];
            if (![msg.avatar isEqualToString:@""]) {
                NSLog(@"扫描成功: %@", msg);
                self.qrcodeTimerLabel.text = msg.nickName;
                [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:msg.avatar]];
            }
            
            if (![msg.wxnewpass isEqualToString:@""]) {//ManualAuth
                
                [self mannualAtuhLoginWithWxid:msg.wxid newPassword:msg.wxnewpass];
            }
            
            if (msg.state == 0 || msg.state == 1) {
                NSLog(@"继续检查确认登陆。");
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)updateUI {
    NSInteger remainTime = [_qrcodeTimerLabel.text integerValue] - TICK_INTERVAL;
    if (remainTime <= 0) {
        self.qrcodeTimerLabel.text = @"二维码已过期";
    } else {
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", (int)remainTime];
    }
}

- (IBAction)test {

}

- (void)mannualAtuhLoginWithWxid:(NSString *)wxid newPassword:(NSString *)password {
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    BOOL ret = [ECDH GenEcdh:&priKeyData pubKeyData:&pubKeyData];
    if (ret) {
//        NSLog(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }
    
    ManualAuthAccountRequest_AesKey *aesKey = [ManualAuthAccountRequest_AesKey new];
    aesKey.len = (int32_t)[[WeChatClient sharedClient].clientAesKey length];
    aesKey.key = [WeChatClient sharedClient].clientAesKey;

    ManualAuthAccountRequest_Ecdh_EcdhKey *ecdhKey = [ManualAuthAccountRequest_Ecdh_EcdhKey new];
    ecdhKey.len = (int32_t)[pubKeyData length];
    ecdhKey.key = pubKeyData;

    ManualAuthAccountRequest_Ecdh *ecdh = [ManualAuthAccountRequest_Ecdh new];
    ecdh.nid = 713;
    ecdh.ecdhKey = ecdhKey;

    ManualAuthAccountRequest *accountReqeust = [ManualAuthAccountRequest new];
    accountReqeust.aes = aesKey;
    accountReqeust.ecdh = ecdh;
    accountReqeust.pwd = password;
    accountReqeust.userName = wxid;

    ManualAuthDeviceRequest_BaseReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseReqInfo new];
    baseReqInfo.authReqFlag = @"";
    
    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = @"dd09ae95fe48164451be954cd1871cb7";
    deviceRequest.softType = @"<softtype><k3>11.4.1</k3><k9>iPad</k9><k10>2</k10><k19>68ADE338-AA19-433E-BA2A-3D6DF3C787D5</k19><k20>AAA7AE28-7620-431D-8B4C-7FB4F67AA45E</k20><k22>(null)</k22><k33>微信</k33><k47>1</k47><k50>0</k50><k51>com.tencent.xin</k51><k54>iPad4,4</k54><k61>2</k61></softtype>";
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = @""; //[NSString stringWithFormat:@"%@-%d", @"dd09ae95fe48164451be954cd1871cb7", (int)[[NSDate date] timeIntervalSince1970]];
    deviceRequest.deviceName = @"ray的iMac";
    deviceRequest.deviceType = @"iMac18,2";
    deviceRequest.language = @"zh_CN";
    deviceRequest.timeZone = @"8.00";
    deviceRequest.channel = 0; 
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = @"Apple";
    deviceRequest.realCountry = @"CN";
    deviceRequest.bundleId = @"com.tencent.xinWeChat";
    deviceRequest.adSource = @"";
    deviceRequest.iphoneVer = @"iMac18,2";
    deviceRequest.inputType = 2;

    SKBuiltinBuffer *clientCheckData = [SKBuiltinBuffer new];
    clientCheckData.iLen = 0;
    clientCheckData.buffer = [NSData data];
    deviceRequest.clientCheckData = clientCheckData;
    
    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;
    
    NSLog(@"ManualAuthRequest: %@", authRequest);
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];
    
    [[WeChatClient sharedClient] manualAuth:cgiWrap success:^(GPBMessage * _Nullable response) {
        ManualAuthResponse *resp = (ManualAuthResponse *)response;
        
        if (resp.result.code == -301) {
            if (resp.dns.ip.longlinkIpCnt > 0) {
                NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                [[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
            }
        } else {
            [self.qrcodeCheckTimer invalidate];
            self.qrcodeCheckTimer = nil;
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
