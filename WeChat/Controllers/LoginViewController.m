//
//  LoginViewController.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LoginViewController.h"
#import "MMWebViewController.h"
#import "AppDelegate.h"
#import "WCECDH.h"
#import "FSOpenSSL.h"
#import "WCSafeSDK.h"
#import "Business.h"
#import <RegexKitLite/RegexKitLite.h>
#import <Ono.h>
// test import
#import "CdnSnsUploadTask.h"
#include <sys/time.h>

@interface LoginViewController ()

@property(weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property(weak, nonatomic) IBOutlet UILabel *versionLabel;

@property(nonatomic, strong) NSData *priKeyData;
@property(nonatomic, strong) NSData *pubKeyData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if PROTOCOL_FOR_ANDROID
    _versionLabel.text = [NSString stringWithFormat:@"Android (0x%x)", CLIENT_VERSION];
#elif PROTOCOL_FOR_IOS
    _versionLabel.text = [NSString stringWithFormat:@"iOS (0x%x)", CLIENT_VERSION];
#endif

    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;

    BOOL ret = [WCECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret) {
        _priKeyData = priKeyData;
        _pubKeyData = pubKeyData;
        LogVerbose(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

//    self.userNameTextField.text = @"dathsp06";
//    self.pwdTextField.text = @"kqrjs496";

    [WeChatClient sharedClient].sessionKey = [FSOpenSSL random128BitAESKey];
    [self autoAuthIfCould];

    unsigned int aa = 3460251153;
    
//    CdnSendPictureTask *task = [CdnSendPictureTask new];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    [task packBody:path];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    CdnSnsUploadTask *snsUploadTask = [CdnSnsUploadTask new];
    NSDictionary *dic = [snsUploadTask parseResponseToDic:data];
    LogVerbose(@"%@", dic);
    
//    message CDNUploadMsgImgPrepareRequest {
//    optional  string  clientImgId  = 1;
//    optional  string  fromUserName  = 2;
//    optional  string  toUserName  = 3;
//    required  int32  thumbHeight  = 4;
//    required  int32  thumbWidth  = 5;
//    optional  string  msgSource  = 6;
//    optional  SKBuiltinBuffer_t  clientStat  = 7;
//    optional  int32  scene  = 8;
//    optional  float  longitude  = 9;
//    optional  float  latitude  = 10;
//    optional  string  attachedContent  = 11;
//    optional  string  aeskey  = 16;
//    optional  int32  encryVer  = 17;
//    optional  uint32  crc32  = 18;
//    optional  uint32  msgForwardType  = 19;
//    optional  uint32  source  = 20;
//    optional  string  appid  = 21;
//    optional  string  messageAction  = 22;
//    optional  string  meesageExt  = 23;
//    optional  string  mediaTagName  = 24;

    
    AccountInfo *accountInfo = [DBManager accountInfo];
    CDNUploadMsgImgPrepareRequest *request = [CDNUploadMsgImgPrepareRequest new];
    request.clientImgId = @"rowhongwei56_1576073040";
    request.fromUserName = accountInfo.userName;
    request.toUserName = @"wxid_30uhdskklyci22";
    request.thumbWidth = 100;
    request.thumbHeight = 100;
    request.msgSource = @"";
    request.scene = 0;
//    request.aeskey =
//    request.crc32 =
    request.msgForwardType = 1;
    request.source = 20;
    request.appid = @"";
    request.messageAction = @"";
    request.meesageExt = @"";
    request.mediaTagName = @"";
    
    
}

- (void)autoAuthIfCould {
    AutoAuthKeyStore *autoAuthKeyStore = [DBManager autoAuthKey];
    if ([autoAuthKeyStore.data length] > 0) {
        //能自动登录自动登录
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self AutoAuth];
        });
    }
}

#pragma mark - Auth

- (IBAction)ManualAuth {
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

    ManualAuthRsaReqData *rsaReqData = [ManualAuthRsaReqData new];
    rsaReqData.randomEncryKey = aesKey;
    rsaReqData.cliPubEcdhkey = cliPubEcdhkey;
    rsaReqData.pwd = [FSOpenSSL md5StringFromString:_pwdTextField.text];
#if PROTOCOL_FOR_ANDROID
    rsaReqData.pwd2 = [FSOpenSSL md5StringFromString:_pwdTextField.text];
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
    aesReqData.signature = device.clientSeqIdsign;
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
    //    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", ClientCheckDataID];
    //    ClientCheckData *ccd = [[ClientCheckData objectsWithPredicate:pre] firstObject];
    //    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    //    clientCheckData.iLen = (int) [ccd.data length];
    //    clientCheckData.buffer = ccd.data;
    //    aesReqData.clientCheckData = clientCheckData;
#endif

    if (CLIENT_VERSION > A703) {
        NSData *extSpamInfoBuffer = [WCSafeSDK getextSpamInfoBufferWithContent:self.userNameTextField.text context:@"&lt;LoginByID&gt"];

        SKBuiltinBuffer_t *extSpamInfo = [SKBuiltinBuffer_t new];
        extSpamInfo.iLen = (int32_t) [extSpamInfoBuffer length];
        extSpamInfo.buffer = extSpamInfoBuffer;

        aesReqData.extSpamInfo = extSpamInfo; // tag=24
    }


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
    if (CLIENT_VERSION >= A700) {
        cgiWrap.cgi = 252;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/secmanualauth";
    }
#endif
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;

    [WeChatClient android700manualAuth:cgiWrap success:^(id _Nullable response) {
        [self onLoginResponse:response];
    }                          failure:^(NSError *_Nonnull error) {

    }];
}

- (void)AutoAuth {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AutoAuthKeyStoreID];
    AutoAuthKeyStore *autoAuthKeyStore = [[AutoAuthKeyStore objectsWithPredicate:pre] firstObject];
    AutoAuthKey *autoAuthKey = [[AutoAuthKey alloc] initWithData:autoAuthKeyStore.data error:nil];

    NSData *sessionKey = [autoAuthKey.encryptKey data];
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

    SKBuiltinBuffer_t *buff = [SKBuiltinBuffer_t new];
    buff.iLen = (uint32_t) [[autoAuthKey data] length];
    buff.buffer = [autoAuthKey data];
    aesReqData.autoAuthKey = buff;

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

    if (CLIENT_VERSION > A703) {
        NSData *extSpamInfoBuffer = [WCSafeSDK getextSpamInfoBufferWithContent:self.userNameTextField.text context:@"auto"];

        SKBuiltinBuffer_t *extSpamInfo = [SKBuiltinBuffer_t new];
        extSpamInfo.iLen = (int32_t) [extSpamInfoBuffer length];
        extSpamInfo.buffer = extSpamInfoBuffer;

        aesReqData.extSpamInfo = extSpamInfo; // tag=24
    }

#if PROTOCOL_FOR_IOS
    //    NSPredicate *clientCheckDataPre = [NSPredicate predicateWithFormat:@"ID = %@", ClientCheckDataID];
    //    ClientCheckData *ccd = [[ClientCheckData objectsWithPredicate:clientCheckDataPre] firstObject];
    //    SKBuiltinBuffer_t *clientCheckData = [SKBuiltinBuffer_t new];
    //    clientCheckData.iLen = (int) [ccd.data length];
    //    clientCheckData.buffer = ccd.data;
    //    aesReqData.clientCheckData = clientCheckData;
#endif
    AutoAuthRequest *authRequest = [AutoAuthRequest new];
    authRequest.aesReqData = aesReqData;
    authRequest.rsaReqData = rsaReqData;

    BaseRequest *baseRequest = [BaseRequest new];
    [baseRequest setSessionKey:[NSData data]];
    AccountInfo *accountInfo = [DBManager accountInfo];
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
#if (PROTOCOL_FOR_ANDROID)
    if (CLIENT_VERSION >= A700) {
        cgiWrap.cgi = 763;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/secautoauth";
        aesReqData.channel = 0;
    }
#endif
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;

    [WeChatClient android700manualAuth:cgiWrap success:^(id _Nullable response) {
        [self onLoginResponse:response];
    }                          failure:^(NSError *_Nonnull error) {

    }];
}

#pragma mark - AuthResponse

- (void)onLoginResponse:(UnifyAuthResponse *)resp {
    LogVerbose(@"%@", resp);
    switch (resp.baseResponse.ret) {
        case -100:
        {
            //        baseResponse {
            //            ret: -100
            //            errMsg {
            //                string: "<e>\n<ShowType>1</ShowType>\n<Content><![CDATA[当前帐号于19:03在ray’s iPhone设备上登录。若非本人操作，你的登录密码可能已经泄漏，请及时改密。紧急情况可前往http://weixin110.qq.com冻结帐号。]]></Content>\n<Url><![CDATA[]]></Url>\n<DispSec>30</DispSec>\n<Title><![CDATA[]]></Title>\n<Action>4</Action>\n<DelayConnSec>0</DelayConnSec>\n<Countdown>0</Countdown>\n<Ok><![CDATA[]]></Ok>\n<Cancel><![CDATA[]]></Cancel>\n</e>\n"
            //            }
            //        }
            
            ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:resp.baseResponse.errMsg.string encoding:NSUTF8StringEncoding error:nil];
            NSString *errorMsg = [[document.rootElement firstChildWithTag:@"Content"] stringValue];
            LogError(@"%@", errorMsg);
            [self alartLoginError:errorMsg];
        }
            break;
            
//        baseResponse {
//            ret: -305 // 要换 NE重新登录，新疆号。
//            errMsg {
//            }
//        }

        case -106: {
            [DBManager clearCookie];
            LogError(@"登录错误: (-106) errMsg: %@", resp.baseResponse.errMsg.string);

            NSString *regex = @"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
            NSString *url = [resp.baseResponse.errMsg.string stringByMatching:regex];
            [self startNaviUrl:url];
        }
            break;
        case -301: { //需要重定向

            LogError(@"登录 -301， 重定向IP。。。");
            [DBManager saveBuiltinIP:resp];
            [DBManager clearCookie];
            [[WeChatClient sharedClient] restart]; // restart

            [self ManualAuth]; // 重新登录
        }
            break;
        case 0: {
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

            if (ret) {
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

                [DBManager saveAutoAuthKey:resp.authSectResp.autoAuthKey.buffer];
                [DBManager saveAccountInfo:uin
                                  userName:resp.acctSectResp.userName
                                  nickName:resp.acctSectResp.nickName
                                     alias:resp.acctSectResp.alias];

                [DBManager saveSessionKey:sessionKey];
                [DBManager saveSelfAsWCContact:resp.acctSectResp.userName
                                      nickName:resp.acctSectResp.nickName];

                [self enterWeChat];
            }
        }
            break;
        default:
            break;
    }
}

- (void)enterWeChat {
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    UINavigationController *nav = [WeChatSB instantiateViewControllerWithIdentifier:@"WeChatTabBarController"];

    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = nav;

    [self startSync];
}

- (void)alartLoginError:(NSString *)errMsg {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearData];
        [self ManualAuth];
    }];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"登录错误" message:errMsg preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)clearData {
    [DBManager clearCookie];
    [DBManager clearAutoAuthKey];
    [DBManager clearSyncKey];
}

- (void)startSync {
    if ([[WeChatClient sharedClient].sync_key_cur length] == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Business newInitWithSyncKeyCur:[WeChatClient sharedClient].sync_key_cur syncKeyMax:[WeChatClient sharedClient].sync_key_max];
        });
    } else {
        [Business newSync];
    }
}

- (void)startNaviUrl:(NSString *)url {
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
    webViewController.url = [NSURL URLWithString:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
