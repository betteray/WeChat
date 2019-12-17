//
//  GetCDNDnsService.m
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "GetCDNDnsService.h"

@implementation GetCDNDnsService

+ (void)getCDNDns
{
    GetCDNDnsRequest *request = [GetCDNDnsRequest new];
    request.scene = 1;
    request.clientIp = @"";
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 379;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/getcdndns";
    cgiWrap.responseClass = [GetCDNDnsResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(GetCDNDnsResponse *_Nullable response) {
                            LogDebug(@"%@", response);
                            [self saveResponse:response];
                      }
                      failure:^(NSError *_Nonnull error){}];
}

+ (void)saveResponse:(GetCDNDnsResponse *)resp {
    NSString *cdnDnsCache = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"cdn_dns.cache"];
    [[resp data] writeToFile:cdnDnsCache atomically:YES];
}

+ (GetCDNDnsResponse *)getCDNDnsResponseFromCache {
    NSString *cdnDnsCache = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"cdn_dns.cache"];
    return [[GetCDNDnsResponse alloc] initWithData:[NSData dataWithContentsOfFile:cdnDnsCache] error:nil];
}

@end
