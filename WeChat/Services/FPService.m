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
    NSData *fpData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mi4-fp" ofType:@"bin"]];
    FPDevice *fp = [FPDevice parseFromData:fpData error:nil];
    NSData *encrypedData = [ZZEncryptService get003FromLocalServer:[fp data]];
    
    SpamInfoEncrypedResult *result = [SpamInfoEncrypedResult parseFromData:encrypedData error:nil];
    result.timestamp = (int32_t)[[NSDate date] timeIntervalSince1970];
    result.tag5 = 5;
    result.tag6 = 0;
    
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


+ (void)fpfresh {
    NSData *fpData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fpdevice-2" ofType:@"bin"]];
    FPDevice *fp = [FPDevice parseFromData:fpData error:nil];
    fp.unknown2 = [ZZEncryptService getFPMd5];
    NSData *encrypedData = [ZZEncryptService get003FromLocalServer:[fp data]];
    
    SpamInfoEncrypedResult *result = [SpamInfoEncrypedResult parseFromData:encrypedData error:nil];
    result.timestamp = (int32_t)[[NSDate date] timeIntervalSince1970];
    result.tag5 = 5;
    result.tag6 = 0;
    
    FPFreshRequest *request = [FPFreshRequest new];
    request.spamBuff = [result data];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 836;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/fpfresh";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [FPFreshResponse class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(FPFreshResponse * _Nullable response) {
        LogVerbose(@"%@", response);
        if (response.baseResponse.ret == 0) {
            [self saveFPData:[SpamBuff parseFromData:response.spamBuff error:nil]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

+ (void)saveFPData:(SpamBuff *)spambuff {
    [FileUtil saveFileWithData:[spambuff.devicetoken dataUsingEncoding:NSUTF8StringEncoding] withFilePath:DEVICE_TOKEN_PATH];
    [FileUtil saveFileWithData:spambuff.soft.softConfig withFilePath:DEVICE_CONFIG_PATH];
    [FileUtil saveFileWithData:spambuff.soft.softData withFilePath:DEVICE_DATA_PATH];
    LogVerbose(@"SaveFPData: %@", spambuff);
}

@end
