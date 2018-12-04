//
//  ShortLink.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLink.h"
#import "NSURLSession+DTAdditions.h"
#import "DNSMgr.h"

@implementation ShortLink

+ (NSData *)mmPost:(NSString *)cgi data:(NSData *)sendData
{
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@", [[DNSMgr sharedMgr] getShortLinkUrl], cgi];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"Accept" forHTTPHeaderField:@"*/*"];
    [request setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
    [request setValue:@"Connection" forHTTPHeaderField:@"close"];
    [request setValue:@"Content-type" forHTTPHeaderField:@"application/octet-stream"];
    [request setValue:@"User-Agent" forHTTPHeaderField:@"MicroMessenger Client"];

    [request setHTTPBody:sendData];
    
    return [NSURLSession requestSynchronousData:request];
}

@end
