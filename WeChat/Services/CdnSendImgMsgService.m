//
//  CdnSendImgMsgService.m
//  WeChat
//
//  Created by ray on 2020/6/2.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CdnSendImgMsgService.h"
#import "FSOpenSSL.h"
#import <zlib.h>

@implementation CdnSendImgMsgService

+ (void)startSendImg:(NSString *)fromUserName toUserName:(NSString *)toUserName pics:(NSDictionary *)picsDict {
    CDNUploadMsgImgPrepareRequest *request = [CDNUploadMsgImgPrepareRequest new];
    NSString *localMsgId = [[[FSOpenSSL random128BitAESKey]  toHexString] substringToIndex:16];
    request.clientImgId = [NSString stringWithFormat:@"aupimg_%@_%ld",localMsgId,[CUtility GetTimeInMilliSecond]];//
    request.fromUserName = fromUserName;
    request.toUserName = toUserName;
    request.thumbHeight = 68;
    request.thumbWidth = 120;
    request.msgSource = @"";
    //    request.clientStat
    request.scene = 0;
    request.longitude = -1000;
    request.latitude = -1000;
    //    request.attachedContent =
//    request.tag12 = 0;
//    request.tag13 = 0;
//    request.tag14 = 0;
//    request.tag15 = 0;
    request.aeskey = [[[FSOpenSSL random128BitAESKey] toHexString] lowercaseString];
    request.encryVer = 0;
   
    NSData *picData = picsDict[@"image"];
    unsigned long crc32 = adler32(0, [picData bytes], (unsigned int) [picData length]);
    
    request.crc32 = (unsigned int)crc32;
    request.msgForwardType = 1;
    request.source = 1;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 625;
    cgiWrap.cmdId = 9;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadmsgimg"; //not important
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [CDNUploadMsgImgPrepareResponse class];
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.userData = picsDict;
    
    [WeChatClient postRequest:cgiWrap success:^(CDNUploadMsgImgPrepareResponse *  _Nullable response) {
        if (response.baseResponse.ret == 0) {
            LogVerbose(@"uploadmsgimg(cdn) Suc: %@", response);
        } else {
            LogVerbose(@"uploadmsgimg(cdn) failed! %@", response);
        }
    } failure:^(NSError * _Nonnull error) {
        LogVerbose(@"uploadmsgimg(cdn) failed: %@", error);
    }];
}

@end
