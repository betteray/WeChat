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
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/fpinitnl";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [FPInitResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient secAuth:cgiWrap success:^(FPInitResponse * _Nullable response) {
        LogVerbose(@"%@", response);
        //response.baseResponse.ret // -29: 03加密第5个int值给不对； -70: 给的03加密数据不对; 10000:
        if (response.baseResponse.ret == 0) {
            SpamBuff *spambuff = [SpamBuff parseFromData:response.spamBuff error:nil];
            [FileUtil saveFileWithData:[spambuff.devicetoken dataUsingEncoding:NSUTF8StringEncoding] withFilePath:DEVICE_TOKEN_PATH];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
