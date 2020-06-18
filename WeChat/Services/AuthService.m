//
//  AuthService.m
//  WeChat
//
//  Created by ray on 2019/12/21.
//  Copyright © 2019 ray. All rights reserved.
//

#import "AuthService.h"
#import "AuthHandler.h"
#import "WCSafeSDK.h"
#import "FSOpenSSL.h"

@implementation AuthService

+ (void)autoAuthWithRootViewController:(UINavigationController *)rootViewController {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AutoAuthKeyStoreID];
    AutoAuthKeyStore *autoAuthKeyStore = [[AutoAuthKeyStore objectsWithPredicate:pre] firstObject];
    AutoAuthKey *autoAuthKey = [[AutoAuthKey alloc] initWithData:autoAuthKeyStore.data error:nil];

    NSData *sessionKey = [autoAuthKey.encryptKey data];
    [WeChatClient sharedClient].sessionKey = sessionKey;

    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t) [sessionKey length];
    aesKey.buffer = sessionKey;

    SKBuiltinBuffer_t *ecdhKey = [SKBuiltinBuffer_t new];
    ecdhKey.iLen = (int32_t) [ [WeChatClient sharedClient].pubKeyData length];
    ecdhKey.buffer =  [WeChatClient sharedClient].pubKeyData;

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

    NSData *extSpamInfoBuffer = [WCSafeSDK getExtSpamInfoWithContent:nil context:@"auto"];

    SKBuiltinBuffer_t *extSpamInfo = [SKBuiltinBuffer_t new];
    extSpamInfo.iLen = (int32_t) [extSpamInfoBuffer length];
    extSpamInfo.buffer = extSpamInfoBuffer;
    aesReqData.extSpamInfo = extSpamInfo; // tag=24

    AutoAuthRequest *authRequest = [AutoAuthRequest new];
    authRequest.aesReqData = aesReqData;
    authRequest.rsaReqData = rsaReqData;

    BaseRequest *baseRequest = [BaseRequest new];
    [baseRequest setSessionKey:[NSData data]];
    AccountInfo *accountInfo = [DBManager accountInfo];
    [baseRequest setUin:accountInfo.uin];
    [baseRequest setScene:2];
    [baseRequest setClientVersion:CLIENT_VERSION];
    [baseRequest setDeviceType:device.osType];
    [baseRequest setDeviceId:device.deviceID];

    [aesReqData setBaseRequest:baseRequest];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 702;
    cgiWrap.cmdId = 254;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/autoauth";
#if (PROTOCOL_FOR_ANDROID)
    if (CLIENT_VERSION >= A700) {
        cgiWrap.cgi = 763;
        cgiWrap.cmdId = 434;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/secautoauth";
        aesReqData.channel = 0;
    }
#endif
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;

    [WeChatClient secAuth:cgiWrap success:^(id _Nullable response) {
        UIViewController *topViewController = [rootViewController.viewControllers objectAtIndex:rootViewController.viewControllers.count-1];
        [AuthHandler onLoginResponse:response from:topViewController loginType:LOGIN_TYPE_AUTOAUTH];
    }                          failure:^(NSError *_Nonnull error) {

    }];
}

+ (void)manualAuthWithViewController:(UIViewController *)viewController userName:(NSString *)userName password:(NSString *)password {
    NSData *sessionKey = [FSOpenSSL random128BitAESKey];
    [WeChatClient sharedClient].sessionKey = sessionKey;
    
    SKBuiltinBuffer_t *aesKey = [SKBuiltinBuffer_t new];
    aesKey.iLen = (int32_t) [sessionKey length];
    aesKey.buffer = sessionKey;
    
    SKBuiltinBuffer_t *ecdhKey = [SKBuiltinBuffer_t new];
    ecdhKey.iLen = (int32_t) [ [WeChatClient sharedClient].pubKeyData length];
    ecdhKey.buffer =  [WeChatClient sharedClient].pubKeyData;
    
    ECDHKey *cliPubEcdhkey = [ECDHKey new];
    cliPubEcdhkey.nid = 713;
    cliPubEcdhkey.key = ecdhKey;
    
    ManualAuthRsaReqData *rsaReqData = [ManualAuthRsaReqData new];
    rsaReqData.randomEncryKey = aesKey;
    rsaReqData.cliPubEcdhkey = cliPubEcdhkey;
    rsaReqData.pwd = [FSOpenSSL md5StringFromString:password];
#if PROTOCOL_FOR_ANDROID
    rsaReqData.pwd2 = [FSOpenSSL md5StringFromString:password];
#endif
    rsaReqData.userName = userName;
    
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
   
    NSData *extSpamInfoBuffer = [WCSafeSDK getExtSpamInfoWithContent:userName context:@"&lt;LoginByID&gt"];
    
    SKBuiltinBuffer_t *extSpamInfo = [SKBuiltinBuffer_t new];
    extSpamInfo.iLen = (int32_t) [extSpamInfoBuffer length];
    extSpamInfo.buffer = extSpamInfoBuffer;
    
    aesReqData.extSpamInfo = extSpamInfo; // tag=24
    
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
        cgiWrap.cmdId = 433;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/secmanualauth";
    }
#endif
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [UnifyAuthResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient secAuth:cgiWrap success:^(id _Nullable response) {
        [AuthHandler onLoginResponse:response from:viewController loginType:LOGIN_TYPE_MANUALAUTH];
    }                          failure:^(NSError *_Nonnull error) {
        
    }];
}

@end
