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
#import "ASIFormDataRequest.h"
#import "FPService.h"

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
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8099"]];
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

+ (NSString *)getFPMd5 {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://10.20.10.49:8080/tool/fp"]];
    NSData *soft_config = [NSData dataWithContentsOfFile:DEVICE_CONFIG_PATH];
    NSData *soft_data = [NSData dataWithContentsOfFile:DEVICE_DATA_PATH];
    [request setPostValue:[soft_config toHexString] forKey:@"soft_config"];
    [request setPostValue:[soft_data toHexString] forKey:@"soft_data"];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    return dic[@"data"][@"md5"];
}

@end
