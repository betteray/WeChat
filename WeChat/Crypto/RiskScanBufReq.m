//
//  RiskScanBufReq.m
//  WeChat
//
//  Created by ray on 2019/10/18.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RiskScanBufReq.h"
#import "FSOpenSSL.h"
#import "NSData+Compression.h"

#import <tup/tup.h>
#import <tup/TarsOutputStream.h>
#import "ReportUserInfo.h"
#import "ReportReq.h"
#import "ReportPhoneType.h"
#import "ReportRequestPacket.h"
#import "RiskScanBufUtil.h"

@implementation RiskScanBufReq

+ (void)test {
    NSString *base64Str = @"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";

//    base64Str = @"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";
    
//    base64Str = @"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";
    
//    base64Str = @"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";
    
//    base64Str = @"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";
    
    base64Str = @"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";
    
    base64Str = @"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";
    
    NSData *decodedData = [FSOpenSSL base64decodeFromString:base64Str];
       
    NSData *key = [RiskScanBufUtil getKey];
    NSData *plainText = [RiskScanBufUtil decrypt:decodedData key:key];

    NSData *decompressedESData = [plainText dataByInflatingWithError:nil];
    NSData *re = [decompressedESData subdataWithRange:NSMakeRange(4, decompressedESData.length - 4)];

    ReportRequestPacket *packet = [ReportRequestPacket fromData:re];
    
    NSData *sBuffer = [packet Tars_sBuffer];
    TarsInputStream *packetStream = [TarsInputStream streamWithData:sBuffer];
    NSDictionary *dict = [packetStream readDictionary:0 required:0 description:[TarsPair pairWithValue:[NSData class] forKey:[NSString class]]];
    
    NSData *phonetypeData = [dict objectForKey:@"phonetype"];
    NSData *reqData = [dict objectForKey:@"req"];
    NSData *userinfoData = [dict objectForKey:@"userinfo"];
    
    TarsInputStream *phonetypeDataStream = [TarsInputStream streamWithData:phonetypeData];
    ReportPhoneType *phoneType = [phonetypeDataStream readAnything:0 required:YES description:[ReportPhoneType class]];
    
    TarsInputStream *reqDataStream = [TarsInputStream streamWithData:reqData];
    ReportReq *reportReq = [reqDataStream readAnything:0 required:YES description:[ReportReq class]];

    TarsInputStream *userinfoDataStream = [TarsInputStream streamWithData:userinfoData];
    ReportUserInfo *reportUserInfo = [userinfoDataStream readAnything:0 required:YES description:[ReportUserInfo class]];

    LogVerbose(@"phoneType = %@", [phoneType yy_modelToJSONString]);
    LogVerbose(@"reportReq = %@", [reportReq yy_modelToJSONString]);
    LogVerbose(@"reportUserInfo = %@", [reportUserInfo yy_modelToJSONString]);
}

+ (NSString *)getRiskScanBufReq {
    
    NSData *uerInfoData  = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UerInfo" ofType:@"bin"]];
    ReportUserInfo *userInfo = [ReportUserInfo fromData:uerInfoData];

    NSData *reqData  = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Req" ofType:@"bin"]];
    ReportReq *req = [ReportReq fromData:reqData];
    
    NSData *phoneTypeData = [NSData dataWithHexString:@"00021100C9"];
    ReportPhoneType *phoneType = [ReportPhoneType fromData:phoneTypeData];
    
    
    TarsOutputStream *uerInfoDataStream = [TarsOutputStream stream];
    [uerInfoDataStream writeAnything:userInfo tag:0 required:NO];
    NSData *uerInfoDataStreamData = [uerInfoDataStream data];
    
    TarsOutputStream *reqDataStream = [TarsOutputStream stream];
    [reqDataStream writeAnything:req tag:0 required:NO];
    NSData *reqDataStreamData = [reqDataStream data];
    
    TarsOutputStream *phoneTypeStream = [TarsOutputStream stream];
    [phoneTypeStream writeAnything:phoneType tag:0 required:NO];
    NSData *phoneTypeStreamData = [phoneTypeStream data];
    
    
    NSDictionary *dict = @{@"phonetype": phoneTypeStreamData,
                                    @"userinfo": uerInfoDataStreamData,
                                    @"req": reqDataStreamData};

    TarsOutputStream *reqeustOutputStream = [TarsOutputStream stream];
    [reqeustOutputStream writeAnything:dict tag:0 required:NO];
    
    ReportRequestPacket *packet = [ReportRequestPacket new];
    [packet setTars_sBuffer:[reqeustOutputStream data]];
    [packet setTars_sFuncName:@"RiskCheck"];
    [packet setTars_sServantName:@"viruscheck"];
    [packet setTars_iVersion:3];
    [packet setTars_cPacketType:0];
    [packet setTars_iMessageType:0];
    [packet setTars_iRequestId:3];
    [packet setTars_iTimeout:0];
    [packet setTars_context:@{}];
    [packet setTars_status:@{}];
    
    NSData *packetData = [packet toData];
    NSData *ESData = [packetData addDataAtHead:[NSData packInt32: (int32_t) ([packetData length] + 4) flip:YES]];
    NSData *compressedESData = [ESData dataByDeflating];
    
    NSData *key = [RiskScanBufUtil getKey];
    NSData *cipherText = [RiskScanBufUtil encrypt:compressedESData key:key];
    return [FSOpenSSL base64FromData:cipherText encodeWithNewlines:NO];
}

@end
