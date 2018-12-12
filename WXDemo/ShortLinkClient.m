//
//  ShortLink.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkClient.h"
#import "DNSMgr.h"
#import <ASIHTTPRequest.h>

@implementation ShortLinkClient

+ (NSData *)mmPost:(NSData *)mmtlsData withHost:(NSString *)headerHost
{
    time_t t = time(NULL);
    srand((unsigned int) t);
    unsigned long long r = rand();
    
    NSString *host = [NSString stringWithFormat:@"http://%@", [[DNSMgr sharedMgr] getShortLinkIp]];
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@", host, [NSString stringWithFormat:@"mmtls/%08llx", r]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstr]];
    [request addRequestHeader:@"Accept" value:@"*/*"];
    [request addRequestHeader:@"Cache-Control" value:@"no-cache"];
    [request addRequestHeader:@"Connection" value:@"close"];
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [request addRequestHeader:@"Host" value:headerHost];
    [request addRequestHeader:@"User-Agent" value:@"MicroMessenger Client"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", [mmtlsData length]]];
    [request addRequestHeader:@"Upgrade" value:@"mmtls"];
    
    [request setAllowCompressedResponse:NO];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[mmtlsData mutableCopy]];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    return [request responseData];
}

@end
