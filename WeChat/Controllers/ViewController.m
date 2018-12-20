//
//  ViewController.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ViewController.h"

#import "Constants.h"
#import "NSData+Util.h"
#import "FSOpenSSL.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "ECDH.h"
#import "NSData+AES.h"
#import <Protobuf/GPBCodedOutputStream.h>
#import "NSData+Util.h"
#import "NSData+CompressAndEncypt.h"

#import "WC_AesGcm128.h"
#import "WC_SHA256.h"
#import "WC_HKDF.h"

#define TICK_INTERVAL 1

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wxid;
@property (weak, nonatomic) IBOutlet UILabel *alias;
@property (weak, nonatomic) IBOutlet UILabel *nickname;

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;

@property (nonatomic, strong) NSData *nofityKey;
@property (nonatomic, assign) NSInteger clientMsgId;

@property (nonatomic, assign) NSData *clientCheckData;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _clientMsgId = 1;
    
}

- (IBAction)checkresUpdate:(id)sender
{
    
}

- (IBAction)getQRCode
{
    LogInfo(@"扫描成功");
    [self.qrcodeCheckTimer invalidate];
    self.qrcodeCheckTimer = nil;

    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t new];
    NSData *sessionKey = [DBManager sharedManager].sessionKey;
    [buffer setILen:(int32_t)[sessionKey length]];
    [buffer setBuffer:sessionKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:0];
    [request setUserName:nil];
    [request setSoftType:nil];
    SKBuiltinBuffer_t *pubKey = [SKBuiltinBuffer_t new];
    pubKey.buffer = [WeChatClient sharedClient].pubKey;
    [pubKey setILen:(int32_t)[[WeChatClient sharedClient].pubKey length]];
    [request setMsgContextPubKey:pubKey];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 502;
    cgiWrap.cmdId = 232;
    cgiWrap.request = request;
    cgiWrap.responseClass = [GetLoginQRCodeResponse class];

    [WeChatClient startRequest:cgiWrap
        success:^(GPBMessage *_Nullable response) {
            LogInfo(@"%@", response);
            GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *) response;

            if (resp)
            {
                self.nofityKey = resp.notifyKey.buffer;
                self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
                self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
                self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
            }

        }
        failure:^(NSError *error) {
            LogError(@"%@", error);
        }];
}

- (void)tick:(NSTimer *)timer
{
    [self updateUI];

    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];

    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t new];
    NSData *sessionKey = [DBManager sharedManager].sessionKey;
    [buffer setILen:[sessionKey length]];
    [buffer setBuffer:sessionKey];
    [request setRandomEncryKey:buffer];

    request.uuid = ((GetLoginQRCodeResponse *) [timer userInfo]).uuid;
    request.timeStamp = [[NSDate date] timeIntervalSince1970];
    request.opcode = 0;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 503;
    cgiWrap.cmdId = 233;
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckLoginQRCodeResponse class];

    [WeChatClient startRequest:cgiWrap
        success:^(GPBMessage *_Nullable response) {
            CheckLoginQRCodeResponse *resp = (CheckLoginQRCodeResponse *) response;
            if (resp.baseResponse.ret == 0)
            {
                NSData *notifyProtobufData = [[resp.notifyPkg.notifyData buffer] aesDecryptWithKey:self.nofityKey];
                NotifyMsg *msg = [NotifyMsg parseFromData:notifyProtobufData error:nil];
                if (![msg.avatar isEqualToString:@""])
                {
                    LogInfo(@"扫描成功: %@", msg);
                    self.qrcodeTimerLabel.text = msg.nickName;
                    [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:msg.avatar]];
                }

                if (![msg.wxnewpass isEqualToString:@""])
                { //ManualAuth

                    [self mannualAtuhLoginWithWxid:msg.wxid newPassword:msg.wxnewpass];
                }

                if (msg.state == 0 || msg.state == 1)
                {
                    LogInfo(@"继续检查确认登陆。");
                }
            }

        }
        failure:^(NSError *error) {
            LogError(@"%@", error);
        }];
}

- (void)updateUI
{
    NSInteger remainTime = [_qrcodeTimerLabel.text integerValue] - TICK_INTERVAL;
    if (remainTime <= 0)
    {
        self.qrcodeTimerLabel.text = @"二维码已过期";
    }
    else
    {
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", (int) remainTime];
    }
}

- (void)mannualAtuhLoginWithWxid:(NSString *)wxid newPassword:(NSString *)password
{
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        //        NSLog(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

    ManualAuthAccountRequest_AesKey *aesKey = [ManualAuthAccountRequest_AesKey new];
    
    NSData *sessionKey = [DBManager sharedManager].sessionKey;
    aesKey.len = (int32_t)[sessionKey length];
    aesKey.key = sessionKey;

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

    ManualAuthDeviceRequest_BaseAuthReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseAuthReqInfo new];
    //TODO: ?第一次登陆没有数据，后续登陆会取一个数据。
    //    baseReqInfo.cliDbencryptInfo = [NSData data];
    //    baseReqInfo.authReqFlag = @"";

    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = @"dd09ae95fe48164451be954cd1871cb7";
    //    deviceRequest.softType = @"<softtype><k3>11.4.1</k3><k9>iPad</k9><k10>2</k10><k19>68ADE338-AA19-433E-BA2A-3D6DF3C787D5</k19><k20>AAA7AE28-7620-431D-8B4C-7FB4F67AA45E</k20><k22>(null)</k22><k33>微信</k33><k47>1</k47><k50>0</k50><k51>com.tencent.xin</k51><k54>iPad4,4</k54><k61>2</k61></softtype>";
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = @""; //[NSString stringWithFormat:@"%@-%d", @"dd09ae95fe48164451be954cd1871cb7", (int)[[NSDate date] timeIntervalSince1970]];
    deviceRequest.deviceName = DEVICEN_NAME;
    deviceRequest.deviceType = @"iMac18,2";
    deviceRequest.language = @"zh_CN";
    deviceRequest.timeZone = @"8.00";
    deviceRequest.channel = 0;
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = @"Apple";
    deviceRequest.realCountry = @"CN";
    deviceRequest.bundleId = @"com.tencent.xinWeChat";
    //    deviceRequest.adSource = @""; //iMac 不需要
    deviceRequest.iphoneVer = @"iMac18,2";
    deviceRequest.inputType = 2;
    deviceRequest.ostype = @"Version 10.13.6 (Build 17G65)";

    //iMac 暂时不需要
    //    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    //    clientCheckData.iLen = 0;
    //    clientCheckData.buffer = [NSData data];
    //    deviceRequest.clientCheckData = clientCheckData;

    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];

    [[WeChatClient sharedClient] manualAuth:cgiWrap
                                    success:^(GPBMessage *_Nullable response) {
                                        ManualAuthResponse *resp = (ManualAuthResponse *) response;

                                        LogInfo(@"登陆响应 Code: %d, msg: %@", resp.result.code, resp.result.errMsg.msg);
                                        switch (resp.result.code)
                                        {
                                            case -301:
                                            { //需要重定向
                                                if (resp.dns.ip.longlinkIpCnt > 0)
                                                {
                                                    NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
//                                                    [[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
                                                }
                                            }
                                            break;
                                            case 0:
                                            { //成功，停止检查二维码
                                                [self.qrcodeCheckTimer invalidate];
                                                self.qrcodeCheckTimer = nil;
                                                self.qrcodeTimerLabel.text = @"登陆成功";

                                                int32_t uin = resp.authParam.uin;
                                                [WeChatClient sharedClient].uin = uin;

                                                int32_t nid = resp.authParam.ecdh.nid;
                                                int32_t ecdhKeyLen = resp.authParam.ecdh.ecdhKey.len;
                                                NSData *ecdhKey = resp.authParam.ecdh.ecdhKey.key;

                                                unsigned char szSharedKey[2048];
                                                int szSharedKeyLen = 0;

                                                BOOL ret = [ECDH DoEcdh:nid
                                                         szServerPubKey:(unsigned char *) [ecdhKey bytes]
                                                          nLenServerPub:ecdhKeyLen
                                                          szLocalPriKey:(unsigned char *) [priKeyData bytes]
                                                           nLenLocalPri:(int) [priKeyData length]
                                                             szShareKey:szSharedKey
                                                           pLenShareKey:&szSharedKeyLen];

                                                if (ret)
                                                {
                                                    NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                                                    NSData * sessionKey = [FSOpenSSL aesDecryptData:resp.authParam.session.key key:checkEcdhKey];
                                                    [[DBManager sharedManager] setSessionKey:sessionKey];
                                                    [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                                                    LogInfo(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                                                          sessionKey,
                                                          uin, resp.accountInfo.wxId,
                                                          resp.accountInfo.nickName,
                                                          resp.accountInfo.alias);

//                                                    [WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                                }
                                            }
                                            break;
                                            default:
                                                break;
                                        }
                                    }
                                    failure:^(NSError *error){

                                    }];
}

@end
