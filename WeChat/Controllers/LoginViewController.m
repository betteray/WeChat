//
//  LoginViewController.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LoginViewController.h"
#import "WCECDH.h"
#import "FSOpenSSL.h"
#import "ClientCheckData.h"
#import "BuiltinIP.h"
#import "AutoAuthKeyStore.h"
#import "AccountInfo.h"
#import "SessionKeyStore.h"
#import "WCContact.h"

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
    
    BOOL ret = [WCECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret)
    {
        _priKeyData = priKeyData;
        _pubKeyData = pubKeyData;
        LogVerbose(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }
    
    [WeChatClient sharedClient].sessionKey = [FSOpenSSL random128BitAESKey];
    
    //能自动登录自动登录
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoAuthIfCould];
    });
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"62" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    LogVerbose(@"%@", obj);
}

- (void)autoAuthIfCould
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AutoAuthKeyStoreID];
    AutoAuthKeyStore *autoAuthKeyStore = [[AutoAuthKeyStore objectsWithPredicate:pre] firstObject];
    if ([autoAuthKeyStore.data length]>0)
    {
        [self AutoAuth];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ManualAuth
{
    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
    [WeChatClient sharedClient].sessionKey = sessionKey;

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
    aesReqData.ostype = [[NSString alloc] initWithData:device.osType encoding:NSUTF8StringEncoding];

#if PROTOCOL_FOR_IOS
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", ClientCheckDataID];
    ClientCheckData *ccd = [[ClientCheckData objectsWithPredicate:pre] firstObject];
    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    clientCheckData.iLen = (int) [ccd.data length];
    clientCheckData.buffer = ccd.data;
    aesReqData.clientCheckData = clientCheckData;
#endif
    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = aesReqData;
    authRequest.rsaReqData = rsaReqData;
    
    BaseRequest *baseRequest = [BaseRequest new];
    [baseRequest setSessionKey:[WeChatClient sharedClient].sessionKey];
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
#if (PROTOCOL_FOR_ANDROID)
    if (CLIENT_VERSION==A700) {
        cgiWrap.cgi = 252;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/secmanualauth";
    }
#endif
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

- (void)AutoAuth
{
    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
    [WeChatClient sharedClient].sessionKey = sessionKey;
    
    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t)[sessionKey length];
    aesKey.buffer = sessionKey;
    
    SKBuiltinBuffer_t *ecdhKey = [SKBuiltinBuffer_t new];
    ecdhKey.iLen = (int32_t)[_pubKeyData length];
    ecdhKey.buffer = _pubKeyData;
    
    ECDHKey *cliPubEcdhkey = [ECDHKey new];
    cliPubEcdhkey.nid = 713;
    cliPubEcdhkey.key = ecdhKey;
    
    AutoAuthRsaReqData *rsaReqData = [AutoAuthRsaReqData new];
    rsaReqData.aesEncryptKey = aesKey;
    rsaReqData.cliPubEcdhkey = cliPubEcdhkey;
    
    ////
    
    BaseAuthReqInfo *baseReqInfo = [BaseAuthReqInfo new];
    //第一次登陆没有数据，后续登陆会取一个数据。
    SKBuiltinBuffer_t *wtloginReqBuff = [SKBuiltinBuffer_t new];
    wtloginReqBuff.iLen = 0;
    wtloginReqBuff.buffer = [NSData data];
    baseReqInfo.wtloginReqBuff = wtloginReqBuff;
    
    WxVerifyCodeReqInfo *verifyCodeReqInfo = [WxVerifyCodeReqInfo new];
    verifyCodeReqInfo.verifySignature = @"";
    verifyCodeReqInfo.verifyContent = @"";
    
    WTLoginImgReqInfo *loginImgReqInfo = [WTLoginImgReqInfo new];
    loginImgReqInfo.imgSid = @"";
    loginImgReqInfo.imgCode = @"";
    loginImgReqInfo.imgEncryptKey = @"";
    SKBuiltinBuffer_t *ksid = [SKBuiltinBuffer_t new];
    ksid.iLen = 0;
    ksid.buffer = [NSData data];
    loginImgReqInfo.ksid = ksid;

    baseReqInfo.wtloginImgReqInfo = loginImgReqInfo;
    baseReqInfo.wxVerifyCodeReqInfo = verifyCodeReqInfo;
    
    SKBuiltinBuffer_t *cliDbencryptKey = [SKBuiltinBuffer_t new];
    cliDbencryptKey.iLen = 0;
    cliDbencryptKey.buffer = [NSData data];
    
    baseReqInfo.cliDbencryptKey = cliDbencryptKey;
    
    SKBuiltinBuffer_t *cliDbencryptInfo = [SKBuiltinBuffer_t new];
    cliDbencryptInfo.iLen = 0;
    cliDbencryptInfo.buffer = [NSData data];
    
    baseReqInfo.cliDbencryptInfo = cliDbencryptInfo;
    baseReqInfo.authReqFlag = 0;
    
    
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    
    AutoAuthAesReqData *aesReqData = [AutoAuthAesReqData new];
    aesReqData.baseReqInfo = baseReqInfo;
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AutoAuthKeyStoreID];
    AutoAuthKeyStore *autoAuthKeyStore = [[AutoAuthKeyStore objectsWithPredicate:pre] firstObject];
    SKBuiltinBuffer_t *autoAuthKey = [SKBuiltinBuffer_t new];
    autoAuthKey.iLen = (uint32_t)[autoAuthKeyStore.data length];
    autoAuthKey.buffer = autoAuthKeyStore.data;
    aesReqData.autoAuthKey = autoAuthKey;
    
    aesReqData.imei = device.imei;
    aesReqData.softType = device.softType;
    aesReqData.builtinIpseq = 0;
    aesReqData.clientSeqId = device.clientSeq;
    aesReqData.signature = device.clientSeqIdsign;
    aesReqData.deviceName = device.deviceName;
    aesReqData.deviceType = device.deviceType;
    aesReqData.language = device.language;
    aesReqData.timeZone = device.timeZone;
    aesReqData.channel = 10003;
    
#if PROTOCOL_FOR_IOS
    NSPredicate *clientCheckDataPre = [NSPredicate predicateWithFormat:@"ID = %@", ClientCheckDataID];
    ClientCheckData *ccd = [[ClientCheckData objectsWithPredicate:clientCheckDataPre] firstObject];
    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    clientCheckData.iLen = (int) [ccd.data length];
    clientCheckData.buffer = ccd.data;
    aesReqData.clientCheckData = clientCheckData;
#endif
    AutoAuthRequest *authRequest = [AutoAuthRequest new];
    authRequest.aesReqData = aesReqData;
    authRequest.rsaReqData = rsaReqData;
    
    BaseRequest *baseRequest = [BaseRequest new];
    [baseRequest setSessionKey:[NSData data]];
    NSPredicate *accountInfoPre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
    AccountInfo *accountInfo = [[AccountInfo objectsWithPredicate:accountInfoPre] firstObject];
    [baseRequest setUin:accountInfo.uin];
    [baseRequest setScene:2];
    [baseRequest setClientVersion:CLIENT_VERSION];
    [baseRequest setDeviceType:[[DeviceManager sharedManager] getCurrentDevice].osType];
    [baseRequest setDeviceId:[[DeviceManager sharedManager] getCurrentDevice].deviceID];
    
    [aesReqData setBaseRequest:baseRequest];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 702;
    cgiWrap.cmdId = 254;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/autoauth";
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [[WeChatClient sharedClient]
     autoAuth:cgiWrap
     success:^(UnifyAuthResponse *_Nullable response) {
         LogVerbose(@"登陆响应 Code: %d, msg: %@", response.baseResponse.ret, response.baseResponse.errMsg);
//         LogVerbose(@"登陆响应: %@", response);
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

            BOOL ret = [WCECDH DoEcdh:nid
                     szServerPubKey:(unsigned char *) [ecdhKey bytes]
                      nLenServerPub:ecdhKeyLen
                      szLocalPriKey:(unsigned char *) [_priKeyData bytes]
                       nLenLocalPri:(int) [_priKeyData length]
                         szShareKey:szSharedKey
                       pLenShareKey:&szSharedKeyLen];

            WCContact *slf = [[WCContact objectsWhere:@"userName = %@", resp.acctSectResp.userName] firstObject];
            
            if (ret)
            {
                NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                NSData *sessionKey = [FSOpenSSL aesDecryptData:resp.authSectResp.sessionKey.buffer key:checkEcdhKey];
                [WeChatClient sharedClient].sessionKey = sessionKey;
                [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                LogVerbose(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                           sessionKey,
                           uin,
                           resp.acctSectResp.userName,
                           resp.acctSectResp.nickName,
                           resp.acctSectResp.alias);

                // 存数据到数据库。
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                for (BuiltinIP *longBuiltinIp in resp.networkSectResp.builtinIplist.longConnectIplistArray) {
                    BuiltinIP *ip = [[BuiltinIP alloc] initWithValue:@{@"isLongIP" : @YES,
                                                                       @"type": @(longBuiltinIp.type),
                                                                       @"port": @(longBuiltinIp.port),
                                                                       @"ip": longBuiltinIp.ip,
                                                                       @"domain": longBuiltinIp.domain}];
                    [realm addOrUpdateObject:ip];
                    
                };

                for (BuiltinIP *longBuiltinIp in resp.networkSectResp.builtinIplist.shortConnectIplistArray) {
                    BuiltinIP *ip = [[BuiltinIP alloc] initWithValue:@{@"isLongIP" : @NO,
                                                                       @"type": @(longBuiltinIp.type),
                                                                       @"port": @(longBuiltinIp.port),
                                                                       @"ip": longBuiltinIp.ip,
                                                                       @"domain": longBuiltinIp.domain}];
                    [realm addOrUpdateObject:ip];
                };
                
                SKBuiltinBuffer_t *autoAuthkey = resp.authSectResp.autoAuthKey;
                [AutoAuthKeyStore createOrUpdateInDefaultRealmWithValue:@[AutoAuthKeyStoreID, autoAuthkey.buffer]];
                
                [AccountInfo createOrUpdateInDefaultRealmWithValue:@[AccountInfoID, @(uin), resp.acctSectResp.userName, resp.acctSectResp.nickName, resp.acctSectResp.alias]];
                
                if (!slf) {
                    [WCContact createOrUpdateInDefaultRealmWithValue:@[resp.acctSectResp.userName,
                                                                       resp.acctSectResp.nickName,
                                                                       @"",
                                                                       @"",
                                                                       @"",
                                                                       @"",
                                                                       @"",
                                                                       @""]];
                }
                
                [SessionKeyStore createOrUpdateInDefaultRealmWithValue:@[SessionKeyStoreID, sessionKey]];
                
                [realm commitWriteTransaction];
                
                [self enterWeChat];
            }
        }
            break;
        default:
            break;
    }
}

- (void)enterWeChat
{
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    UINavigationController *nav = [WeChatSB instantiateViewControllerWithIdentifier:@"WeChatTabBarController"];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
