//
//  PasswordService.m
//  WeChat
//
//  Created by ray on 2020/5/20.
//  Copyright © 2020 ray. All rights reserved.
//

#import "PasswordService.h"
#import "FSOpenSSL.h"

@implementation PasswordService

+ (void)NewverifyPasswd:(NSString *)curPassword newPassword:(NSString *)newPassword {
    
    VerifyPswdRequest *request = [VerifyPswdRequest new];
    request.opCode = 1;
    request.pwd1 = [FSOpenSSL md5StringFromString:curPassword];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 384;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newverifypasswd";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [VerifyPswdResponse class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(VerifyPswdResponse *  _Nullable response) {
        if (response.baseResponse.ret == 0) {
            LogVerbose(@"NewverifyPasswd Suc!!!");
            if (newPassword.length) {
                [self newsetpasswd:newPassword ticket:response.ticket];
            }
        } else {
            LogVerbose(@"NewverifyPasswd failed!!!");
        }
    } failure:^(NSError * _Nonnull error) {
        LogVerbose(@"NewverifyPasswd failed: %@", error);
    }];
    
}

+ (void)newsetpasswd:(NSString *)newPassword ticket:(NSString *)ticket {
    SetPwdRequest *request = [SetPwdRequest new];
    request.ticket = ticket;
    request.ticketType = 1;
    request.password = [FSOpenSSL md5StringFromString:newPassword];
    
    AutoAuthKeyStore *autoAuthKeyStore = [DBManager autoAuthKey];
    SKBuiltinBuffer_t *key = [SKBuiltinBuffer_t new];
    key.iLen = (int) autoAuthKeyStore.data.length;
    key.buffer = autoAuthKeyStore.data;
    request.autoAuthKey = key;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 383;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newsetpasswd";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [SetPwdResponse class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(SetPwdResponse *  _Nullable response) {
        if (response.baseResponse.ret == 0) {
            LogVerbose(@"newsetpasswd Suc!!!");
            [DBManager saveAutoAuthKey:response.autoAuthKey.buffer];
        } else {
            LogVerbose(@"newsetpasswd failed!!!");
        }
    } failure:^(NSError * _Nonnull error) {
        LogVerbose(@"newsetpasswd failed: %@", error);
    }];
}

@end
