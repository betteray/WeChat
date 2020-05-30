//
//  WCSafeSDK.m
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import "WCSafeSDK.h"
#import "FSOpenSSL.h"

#import "ZZEncryptService.h"

#import "SpamInfoGenerator-Proto.h"
#import "SpamInfoGenerator-XML.h"
#import "FPService.h"
#import "CUtility.h"

@implementation WCSafeSDK

+ (NSData *)getExtSpamInfoWithContent:(nullable NSString *)content
                              context:(NSString *)context {
   BOOL needGenTouchData = content.length > 0;
   WCExtInfo *extInfo = [WCExtInfo new];
    
    if (needGenTouchData) {
        NSData *WCSTFData = nil;
        NSData *WCSTEData = nil;
        if (CLIENT_VERSION > A706) {
            NSData *WCSTF = [SpamInfoGenerator_Proto genWCSTFWithAccount:content];
            WCSTFData = [ZZEncryptService get003FromLocal:WCSTF];
            
            NSData *WCSTE = [SpamInfoGenerator_Proto genWCSTEWithContext:context];
            WCSTEData = [ZZEncryptService get003FromLocal:WCSTE];
        } else {
            NSString *WCSTF = [SpamInfoGenerator_XML genWCSTFWithAccount:content];
            WCSTFData = [ZZEncryptService get003FromLocal:WCSTF];
            
            NSString *WCSTE = [SpamInfoGenerator_XML genWCSTEWithContext:context];
            WCSTEData = [ZZEncryptService get003FromLocal:WCSTE];
        }
        SKBuiltinBuffer_t *wcstf = [SKBuiltinBuffer_t new];
        wcstf.iLen = (int32_t) [WCSTFData length];
        wcstf.buffer = WCSTFData;
        extInfo.wcstf = wcstf;
        
        SKBuiltinBuffer_t *wcste = [SKBuiltinBuffer_t new];
        wcste.iLen = (int32_t) [WCSTEData length];
        wcste.buffer = WCSTEData;
        
        extInfo.wcste = wcste;
    }
   
    NSData *STData = nil;
    if (CLIENT_VERSION > A706) {
        ClientSpamInfoType type = ClientSpamInfoType_Login;
        if ([context isEqualToString:@"report"]) {
            type = ClientSpamInfoType_Report;
        }
        
        NSData *ST = [SpamInfoGenerator_Proto getClientSpamInfoType:type]; // 0 登录用
        STData = [ZZEncryptService get003FromLocal:ST];
    } else {
        NSString *ST = [SpamInfoGenerator_XML genST:0]; // 0 登录用
        STData = [ZZEncryptService get003FromLocal:ST];
    }
    
    SKBuiltinBuffer_t *ccData = [SKBuiltinBuffer_t new];
    ccData.iLen = (int32_t) [STData length];
    ccData.buffer = STData;
    
    extInfo.ccData = ccData;
    
    if (CLIENT_VERSION >= A7011) {
        DeviceToken *dt = [DeviceToken new];
        dt.tag1 = @"";
        dt.tag2 = 1;
        DeviceToken_Token *token = [DeviceToken_Token new];
        token.devicetoken = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:DEVICE_TOKEN_PATH] encoding:NSUTF8StringEncoding];
        dt.token = token;
        dt.timestamp = (uint32_t) [CUtility GetTimeStamp];
        
        SKBuiltinBuffer_t *deviceTokenBuffer = [SKBuiltinBuffer_t new];
        NSData *dtData = [dt data];
        deviceTokenBuffer.iLen = (uint32_t) dtData.length;
        deviceTokenBuffer.buffer = dtData;
        
        extInfo.deviceToken = deviceTokenBuffer;
    }
    
    return [extInfo data];
}

@end

