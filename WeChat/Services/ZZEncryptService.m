//
//  ZZEncryptService.m
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import "ZZEncryptService.h"
#import "FSOpenSSL.h"
#import "ASIHTTPRequest.h"

@implementation ZZEncryptService

+ (NSData *)get003FromLocalServer:(id)protoOrXml {
    NSData *postBody = nil;
    if ([protoOrXml isKindOfClass:[NSString class]]) { // xml
        NSString *base64String = [FSOpenSSL base64FromString:protoOrXml encodeWithNewlines:NO];
        postBody = [base64String dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([protoOrXml isKindOfClass:[NSData class]]) { // proto
        NSString *base64String = [FSOpenSSL base64FromData:protoOrXml encodeWithNewlines:NO];
        postBody = [base64String dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://10.20.10.232:8099"]];
    request.postBody = [postBody mutableCopy];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
        return [NSData new];
    }
    
    return [request responseData];
}

@end
