//
//  ShortLinkClient.m
//  WeChat
//
//  Created by ray on 2018/12/25.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkClient.h"
#import <ASIHTTPRequest.h>

@implementation ShortLinkClient

+ (NSData *)post:(NSData *)data toCgiPath:(NSString *)cgiPath
{
    NSString *host = [NSString stringWithFormat:@"http://%@%@", @"163.177.81.139", cgiPath];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:host]];
    [request addRequestHeader:@"Accept" value:@"*/*"];
//    [request addRequestHeader:@"Accept-Encoding" value:@"identity"];
    [request addRequestHeader:@"Cache-Control" value:@"no-cache"];
    [request addRequestHeader:@"Connection" value:@"close"];
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [request addRequestHeader:@"User-Agent" value:@"MicroMessenger Client"];
    
    [request setAllowCompressedResponse:NO];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[data mutableCopy]];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
    }
    
    return [request responseData];
}

@end
