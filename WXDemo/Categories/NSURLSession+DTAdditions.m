//
//  NSURLSession+DTAdditions.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "NSURLSession+DTAdditions.h"

@implementation NSURLSession (DTAdditions)

+ (NSData *)requestSynchronousData:(NSURLRequest *)request
{
    __block NSData *data = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
        data = taskData;
        if (!data) {
            LogError(@"%@", error);
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return data;
}

+ (NSData *)requestSynchronousDataWithURLString:(NSString *)requestString
{
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self requestSynchronousData:request];
}

+ (NSDictionary *)requestSynchronousJSON:(NSURLRequest *)request
{
    NSData *data = [self requestSynchronousData:request];
    NSError *e = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    return jsonData;
}

+ (NSDictionary *)requestSynchronousJSONWithURLString:(NSString *)requestString
{
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:50];
    theRequest.HTTPMethod = @"GET";
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return [self requestSynchronousJSON:theRequest];
}

@end
