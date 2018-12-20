//
//  LoginViewController.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LoginViewController.h"
#import "ECDH.h"
#import "FSOpenSSL.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ManualAuth
{
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;

    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        LogInfo(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
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
    accountReqeust.pwd = [FSOpenSSL md5FromString:_pwdTextField.text]; //@"a4e1442774cc2eda89feb8ae66a33c8b"
    accountReqeust.userName = _userNameTextField.text;

    ManualAuthDeviceRequest_BaseAuthReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseAuthReqInfo new];
    //第一次登陆没有数据，后续登陆会取一个数据。
    //baseReqInfo.cliDbencryptInfo = [NSData data];
    baseReqInfo.authReqFlag = @"";

    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = IMEI;
    deviceRequest.softType = SOFT_TYPE;
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = CLIENT_SEQ_ID;
    deviceRequest.deviceName = DEVICEN_NAME;
    deviceRequest.deviceType = @"iPhone"; //"DEVICE_TYPE;
    deviceRequest.language = LANGUAGE;
    deviceRequest.timeZone = TIME_ZONE;
    deviceRequest.channel = CHANEL;
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = DEVICE_BRAND;
    deviceRequest.realCountry = REAL_COUNTRY;
    deviceRequest.bundleId = BUNDLE_ID;
    deviceRequest.adSource = AD_SOURCE; //iMac 不需要
    deviceRequest.iphoneVer = IPHONE_VER;
    deviceRequest.inputType = 2;
    deviceRequest.ostype = OS_TYPE;

    //iMac 暂时不需要

    NSData *data = [[DBManager sharedManager] getClientCheckData];
    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    clientCheckData.iLen = (int) [data length];
    clientCheckData.buffer = data;
    deviceRequest.clientCheckData = clientCheckData;

    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/manualauth";
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;

    [[WeChatClient sharedClient]
        manualAuth:cgiWrap
           success:^(GPBMessage *_Nullable response) {
               ManualAuthResponse *resp = (ManualAuthResponse *) response;

               LogVerbose(@"登陆响应 Code: %d, msg: %@", resp.result.code, resp.result.errMsg.msg);

               switch (resp.result.code)
               {
                   case -301:
                   { //需要重定向
                       if (resp.dns.ip.longlinkIpCnt > 0)
                       {
                           NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                           //[[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
                       }
                   }
                   break;
                   case 0:
                   {
                       int64_t uin = resp.authParam.uin;
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
                           NSData *sessionKey = [FSOpenSSL aesDecryptData:resp.authParam.session.key key:checkEcdhKey];
                           [[DBManager sharedManager] setSessionKey:sessionKey];
                           [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                           LogVerbose(@"登陆成功: SessionKey: %@, uin: %lld, wxid: %@, NickName: %@, alias: %@",
                                      sessionKey,
                                      uin, resp.accountInfo.wxId,
                                      resp.accountInfo.nickName,
                                      resp.accountInfo.alias);

//                           [WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];

                           [WXUserDefault saveUIN:uin];
                           [WXUserDefault saveWXID:resp.accountInfo.wxId];
                           [WXUserDefault saveNikeName:resp.accountInfo.nickName];
                           [WXUserDefault saveAlias:resp.accountInfo.alias];

                           UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
                           UINavigationController *nav = [WeChatSB instantiateViewControllerWithIdentifier:@"NavFunctionsViewController"];
                           [self presentViewController:nav animated:YES completion:nil];
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
