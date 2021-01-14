//
//  FPService.m
//  WeChat
//
//  Created by ray on 2020/2/25.
//  Copyright © 2020 ray. All rights reserved.
//

#import "FPService.h"
#import "WCSafeSDK.h"
#import "FSOpenSSL.h"
#import "ZZEncryptService.h"
#import "FileUtil.h"

@implementation FPService

+ (void)initFP {
    FPDevice *fp = [[DeviceManager sharedManager] getCurrentDevice].fpDevice;
    NSData *encrypedData = [ZZEncryptService get003FromLocal:[fp data]];
    
    ClientCheckData *result = [ClientCheckData parseFromData:encrypedData error:nil];
    result.timeStamp = (int32_t)[[NSDate date] timeIntervalSince1970];
    result.dataType = ClientCheckData_DataType_CcdataPbZipWb;
    result.status = ClientCheckData_Status_CcdataSuccess;
    
    FPInitRequest *request = [FPInitRequest new];
    request.spamBuff = [result data];
    request.randomkey = [WeChatClient sharedClient].sessionKey;
   
    BaseRequest *base = [BaseRequest new];
    [base setSessionKey:[NSData data]];
    [base setUin:0];
    [base setScene:0];
    [base setClientVersion:CLIENT_VERSION];
    [base setDeviceType:[[DeviceManager sharedManager] getCurrentDevice].osType];
    [base setDeviceId:[[DeviceManager sharedManager] getCurrentDevice].deviceID];
    request.baseRequest = base;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 3789;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/fpinitnl"; //  nl == nologin ?
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [FPInitResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient secAuth:cgiWrap success:^(FPInitResponse * _Nullable response) {
        if (response.baseResponse.ret == 0) {
            [self saveFPData:[SpamBuff parseFromData:response.spamBuff error:nil]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


+ (void)fpfresh:(BOOL)hasLogin {
    FPDevice *fp = [[DeviceManager sharedManager] getCurrentDevice].fpDevice;
    fp.unknown2 = [ZZEncryptService getFPMd5];
    NSData *encrypedData = [ZZEncryptService get003FromLocal:[fp data]];
    
    FPFreshRequest *request = [FPFreshRequest new];
    request.spamBuff = encrypedData;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 836;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/fpfresh";
    if (!hasLogin) {
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/fpfreshnl";
        cgiWrap.cgi = 3944;
    }
    cgiWrap.request = request;
    cgiWrap.responseClass = [FPFreshResponse class];
    cgiWrap.needSetBaseRequest = YES;
    
    if (!hasLogin) {
        BaseRequest *base = [BaseRequest new];
        NSData *sessionKey = [WeChatClient sharedClient].sessionKey;
        [base setSessionKey:sessionKey];

        AccountInfo *accountInfo = [DBManager accountInfo];
        [base setUin:accountInfo.uin];
        [base setScene:0]; // iMac 1
        [base setClientVersion:CLIENT_VERSION];
        [base setDeviceType:[[DeviceManager sharedManager] getCurrentDevice].osType];
        [base setDeviceId:[[DeviceManager sharedManager] getCurrentDevice].deviceID];
        
        request.baseRequest = base;
        
        [WeChatClient secAuth:cgiWrap success:^(FPFreshResponse * _Nullable response) {
            LogVerbose(@"%@", response);
            if (response.baseResponse.ret == 0) {
                [self saveFPData:[SpamBuff parseFromData:response.spamBuff error:nil]];
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [WeChatClient postRequest:cgiWrap success:^(FPFreshResponse * _Nullable response) {
            LogVerbose(@"%@", response);
            if (response.baseResponse.ret == 0) {
                [self saveFPData:[SpamBuff parseFromData:response.spamBuff error:nil]];
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

+ (void)saveFPData:(SpamBuff *)spambuff {
    [FileUtil saveFileWithData2:[spambuff.devicetoken dataUsingEncoding:NSUTF8StringEncoding] withFilePath:DEVICE_TOKEN_PATH];
    [FileUtil saveFileWithData2:spambuff.soft.softConfig withFilePath:DEVICE_CONFIG_PATH];
    [FileUtil saveFileWithData2:spambuff.soft.softData withFilePath:DEVICE_DATA_PATH];
    LogVerbose(@"SaveFPData: %@", spambuff);
}

@end
