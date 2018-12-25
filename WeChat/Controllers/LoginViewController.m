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

@property (nonatomic, strong) NSData *priKeyData;
@property (nonatomic, strong) NSData *pubKeyData;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    
    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        _priKeyData = priKeyData;
        _pubKeyData = pubKeyData;
        LogInfo(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }
    
    _userNameTextField.text = @"13520806231";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ManualAuth
{
    NSData *sessionKey = [DBManager sharedManager].sessionKey;
    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t)[sessionKey length];
    aesKey.buffer = sessionKey;

    SKBuiltinBuffer_t *ecdhKey = [SKBuiltinBuffer_t new];
    ecdhKey.iLen = (int32_t)[_pubKeyData length];
    ecdhKey.buffer = _pubKeyData;

    ECDHKey *cliPubEcdhkey = [ECDHKey new];
    cliPubEcdhkey.nid = 713;
    cliPubEcdhkey.key = ecdhKey;

    ManualAuthRsaReqData *rsaReqData = [ManualAuthRsaReqData new];
    rsaReqData.randomEncryKey = aesKey;
    rsaReqData.cliPubEcdhkey = cliPubEcdhkey;
    rsaReqData.pwd = [FSOpenSSL md5FromString:_pwdTextField.text];
#if PROTOCOL_FOR_ANDROID
    rsaReqData.pwd2 = [FSOpenSSL md5FromString:_pwdTextField.text];
#endif
    rsaReqData.userName = _userNameTextField.text;

    BaseAuthReqInfo *baseReqInfo = [BaseAuthReqInfo new];
    //第一次登陆没有数据，后续登陆会取一个数据。
    //baseReqInfo.cliDbencryptInfo = [NSData data];
#if PROTOCOL_FOR_IOS
    baseReqInfo.authReqFlag = @"";
#endif
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    
    ManualAuthAesReqData *aesReqData = [ManualAuthAesReqData new];
    aesReqData.baseReqInfo = baseReqInfo;
    aesReqData.imei = device.imei;
    aesReqData.softType = device.softType;
    aesReqData.builtinIpseq = 0;
    aesReqData.clientSeqId = device.clientSeq;
#if PROTOCOL_FOR_ANDROID
    aesReqData.clientSeqIdsign = device.clientSeqIdsign;
#endif
    aesReqData.deviceName = device.deviceName;
    aesReqData.deviceType = device.deviceType;
    aesReqData.language = device.language;
    aesReqData.timeZone = device.timeZone;
    aesReqData.channel = (int32_t) device.chanel;
#if PROTOCOL_FOR_IOS
    aesReqData.timeStamp = [[NSDate date] timeIntervalSince1970];
#elif PROTOCOL_FOR_ANDROID
    aesReqData.timeStamp = 0;
#endif
    aesReqData.deviceBrand = device.deviceBrand;
#if PROTOCOL_FOR_ANDROID
    aesReqData.deviceModel = device.deviceModel;
#endif
    aesReqData.realCountry = device.realCountry;
#if PROTOCOL_FOR_IOS
    aesReqData.bundleId = device.bundleID;
    aesReqData.adSource = device.adSource; //iMac 不需要
    aesReqData.iphoneVer = device.iphoneVer;
#endif
    aesReqData.inputType = 2;
    aesReqData.ostype = device.osType;

#if PROTOCOL_FOR_IOS
    //iMac 暂时不需要
    NSData *data = [[DBManager sharedManager] getClientCheckData];
    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    clientCheckData.iLen = (int) [data length];
    clientCheckData.buffer = data;
    aesReqData.clientCheckData = clientCheckData;
#endif
    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = aesReqData;
    authRequest.rsaReqData = rsaReqData;
    
    BaseRequest *baseRequest = [BaseRequest new];
    [baseRequest setSessionKey:[DBManager sharedManager].sessionKey];
    [baseRequest setUin:0];
#if PROTOCOL_FOR_IOS
    [baseRequest setScene:0];
#elif PROTOCOL_FOR_ANDROID
    [baseRequest setScene:1];
#endif
    [baseRequest setClientVersion:CLIENT_VERSION];
    [baseRequest setDeviceType:[[DeviceManager sharedManager] getCurrentDevice].osType];
    [baseRequest setDeviceId:[[DeviceManager sharedManager] getCurrentDevice].deviceID];
    
    [aesReqData setBaseRequest:baseRequest];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/manualauth";
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;

    [[WeChatClient sharedClient]
        manualAuth:cgiWrap
           success:^(UnifyAuthResponse *_Nullable response) {
               LogVerbose(@"登陆响应 Code: %d, msg: %@", response.baseResponse.ret, response.baseResponse.errMsg);
               [self onLoginResponse:response];
           }
           failure:^(NSError *error){

           }];
}

- (void)onLoginResponse:(UnifyAuthResponse *)resp
{
    switch (resp.baseResponse.ret)
    {
        case -301:
        { //需要重定向
            if (resp.networkSectResp.builtinIplist.longConnectIpcount > 0)
            {
                //NSString *longlinkIp = [[resp.networkSectResp.builtinIplist.longConnectIplistArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                //[[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
            }
        }
        break;
        case 0:
        {
            int32_t uin = resp.authSectResp.uin;
            [WeChatClient sharedClient].uin = uin;

            int32_t nid = resp.authSectResp.svrPubEcdhkey.nid;
            int32_t ecdhKeyLen = resp.authSectResp.svrPubEcdhkey.key.iLen;
            NSData *ecdhKey = resp.authSectResp.svrPubEcdhkey.key.buffer;

            unsigned char szSharedKey[2048];
            int szSharedKeyLen = 0;

            BOOL ret = [ECDH DoEcdh:nid
                     szServerPubKey:(unsigned char *) [ecdhKey bytes]
                      nLenServerPub:ecdhKeyLen
                      szLocalPriKey:(unsigned char *) [_priKeyData bytes]
                       nLenLocalPri:(int) [_priKeyData length]
                         szShareKey:szSharedKey
                       pLenShareKey:&szSharedKeyLen];

            if (ret)
            {
                NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                NSData *sessionKey = [FSOpenSSL aesDecryptData:resp.authSectResp.sessionKey.buffer key:checkEcdhKey];
                [[DBManager sharedManager] setSessionKey:sessionKey];
                [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                LogVerbose(@"登陆成功: SessionKey: %@, uin: %ld, wxid: %@, NickName: %@, alias: %@",
                           sessionKey,
                           uin,
                           resp.acctSectResp.userName,
                           resp.acctSectResp.nickName,
                           resp.acctSectResp.alias);

                //[WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];

                [WXUserDefault saveUIN:uin];
                [WXUserDefault saveWXID:resp.acctSectResp.userName];
                [WXUserDefault saveNikeName:resp.acctSectResp.nickName];
                [WXUserDefault saveAlias:resp.acctSectResp.alias];

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

@end
