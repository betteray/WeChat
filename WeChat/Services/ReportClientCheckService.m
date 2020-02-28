//
//  ReportClientCheckService.m
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import "ReportClientCheckService.h"
#import "SpamInfoGenerator-XML.h"
#import "ZZEncryptService.h"

@implementation ReportClientCheckService

+ (void)reportClientCheckWithContext:(uint64_t)context basic:(BOOL)basic
{
    NSString *xml = nil;

    if (basic) {
        xml = [SpamInfoGenerator_XML genBasicST];
    } else {
        xml = [SpamInfoGenerator_XML genST:15];
    }
    
    NSData *encrypedXMLBuffer = [ZZEncryptService get003FromLocalServer:xml];
    ReportClientCheckReq *req = [[ReportClientCheckReq alloc] init];
    req.encryptedXmlbuffer = encrypedXMLBuffer;
    req.reportContext = context;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 771;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/reportclientcheck";
    cgiWrap.request = req;
    cgiWrap.responseClass = [ReportClientCheckResp class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(ReportClientCheckResp * _Nullable response) {
        LogVerbose(@"ReportClientCheckResp = %@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

@end
