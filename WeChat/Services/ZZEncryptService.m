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
#import "NSData+Compression.h"
#import "encrypt.h"

@implementation ZZEncryptService

+ (NSData *)get003FromServer:(id)protoOrXml {
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

+ (NSData *)get003FromLocal:(id)protoOrXml {
    NSParameterAssert([protoOrXml isKindOfClass:[NSData class]] || [protoOrXml isKindOfClass:[NSString class]]);
    
    NSData *postBody = nil;
    if ([protoOrXml isKindOfClass:[NSString class]]) { // xml
        postBody = [[protoOrXml dataUsingEncoding:NSUTF8StringEncoding] dataByDeflating];
    }
    
    if ([protoOrXml isKindOfClass:[NSData class]]) { // proto
        postBody = [protoOrXml dataByDeflating];
    }

    NSData *zlibCompressedSaeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sae-zlib-compress" ofType:@"bin"]];
    NSData *unCompressedSaeData = [zlibCompressedSaeData dataByInflatingWithError:nil];
    wcaes *aes = [wcaes parseFromData:unCompressedSaeData error:nil];

    NSData *saeIV = aes.iv;
    NSData *tableKey = aes.tablekey;
    NSData *tableValue = aes.tablevalue;
    NSData *tableFinal = aes.unkown18;

    char outbuff[postBody.length * 2];
    unsigned int  outlen = 0;
    
    int ret = [ENC nativewcswbaes:"",
                   (char *) postBody.bytes, (unsigned int) postBody.length,
                   (char *) saeIV.bytes, (unsigned int) saeIV.length,
                   (char *) tableKey.bytes, (unsigned int) tableKey.length,
                   (char *) tableValue.bytes, (unsigned int) tableValue.length,
                   (char *) tableFinal.bytes, (unsigned int) tableFinal.length,
                   0x3060,
                   outbuff, &outlen];
    
    if (ret == 1) {
        NSData *data = [NSData dataWithBytes:outbuff length:outlen];
        SpamInfoEncrypedResult *result = [SpamInfoEncrypedResult new];
        result.type = 1;
        result.version = @"00000003\000";
        result.encrypedData = data;
        result.timestamp = (int32_t)[[NSDate date] timeIntervalSince1970];
        result.tag5 = 5;
        result.tag6 = 0;
        
        return [result data];
    }
   
    
    return nil;
}

@end
