//
//  WCSafeSDK.m
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import "WCSafeSDK.h"
#import "NSData+CRC32.h"
#import "ASIFormDataRequest.h"

@implementation WCSafeSDK

+ (NSData *)get003FromLocalServer:(NSString *)xml {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://10.20.10.22:8099"]];
    [request addPostValue:xml forKey:@"postData"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
    }
    
    return [request responseData];
}

+ (void)reportClientCheckWithContext:(uint64_t)context {
    NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"st" ofType:@"bin"]];
    NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdcc>714570694</ccdcc>" withString:@""];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdts>1571129457</ccdts>" withString:@""];
    
    NSString *versionXML = [NSString stringWithFormat:@"<ClientVersion>0x%x</ClientVersion>", CLIENT_VERSION];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ClientVersion>0x27000634</ClientVersion>" withString:versionXML];
    
    uint32_t crc32Result = [[xml dataUsingEncoding:NSUTF8StringEncoding] crc32];
    xml = [NSString stringWithFormat:@"%@<ccdcc>%d</ccdcc><ccdts>%ld</ccdts>", xml, crc32Result, time(0)];
    
    NSData *encrypedXMLBuffer = [self get003FromLocalServer:xml];
    
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
