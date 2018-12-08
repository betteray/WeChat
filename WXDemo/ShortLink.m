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

+ (NSData *)mmPost:(NSString *)cgi data:(NSData *)mmtlsData
{
    time_t t = time(NULL);
    srand((unsigned int) t);
    unsigned long long r = rand();

    NSString *urlstr = [NSString stringWithFormat:@"%@/%@", @"http://szextshort.weixin.qq.com", [NSString stringWithFormat:@"/mmtls/%08llx", r]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
    request.HTTPMethod = @"POST";

    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"MicroMessenger Client" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[NSString stringWithFormat:@"%ld", [mmtlsData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"mmtls" forHTTPHeaderField:@"Upgrade"];

    [request setHTTPBody:mmtlsData];

    return [NSURLSession requestSynchronousData:request];
}

@end
