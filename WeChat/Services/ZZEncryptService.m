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

//    NSData *unCompressedSaeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"meta-manifest" ofType:@"dat"]];
    NSData *unCompressedSaeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"key.bin" ofType:@""]];
    wcaes *aes = [wcaes parseFromData:unCompressedSaeData error:nil];

    NSData *tbkey = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sectable.bin" ofType:@""]];
    NSData *tbvalue = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sectablevalue.bin" ofType:@""]];

    
    NSData *saeIV = aes.iv;
    NSData *tableKey = aes.tablekey;
    NSData *tableValue = aes.tablevalue;
    NSData *tableFinal = aes.unkown18;

    tableKey = tbkey;
    tableValue = tbvalue;

    char outbuff[postBody.length * 2];
    unsigned int  outlen = 0;
    
    int ret = [ENC nativewcswbaes:"",
                   (char *) postBody.bytes, (unsigned int) postBody.length,
                   (char *) saeIV.bytes, (unsigned int) saeIV.length,
                   (char *) tableKey.bytes, (unsigned int) tableKey.length,
                   (char *) tableValue.bytes, (unsigned int) tableValue.length,
                   (char *) tableFinal.bytes, (unsigned int) tableFinal.length,
                   aes.len,
                   outbuff, &outlen];
    
    if (ret == 1) {
        NSData *data = [NSData dataWithBytes:outbuff length:outlen];
        ClientCheckData *result = [ClientCheckData new];
        result.type = 2;
        result.version = @"00000001\000";
        result.clientCheckData = data;
        result.timeStamp = (int32_t)[[NSDate date] timeIntervalSince1970];
        result.dataType = ClientCheckData_DataType_CcdataPbZipWb;
        result.status = ClientCheckData_Status_CcdataSuccess;
        
        return [result data];
    }
   
    
    return nil;
}

@end
