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
