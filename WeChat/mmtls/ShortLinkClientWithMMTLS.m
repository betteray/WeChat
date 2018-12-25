

//
//  ShortLink.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkClientWithMMTLS.h"
#import "DNSManager.h"
#import <ASIHTTPRequest.h>

#import "ShortLinkWithMMTLS.h"
#import "MMTLSShortLinkResponse.h"

@interface ShortLinkClientWithMMTLS ()

@property (nonatomic, strong) NSData *decryptedPart2;
@property (nonatomic, strong) NSData *resumptionSecret;

@end

@implementation ShortLinkClientWithMMTLS

- (instancetype)initWithDecryptedPart2:(NSData *)decryptedPart2 resumptionSecret:(NSData *)resumptionSecret
{
    self = [super init];
    if (self)
    {
        _decryptedPart2 = decryptedPart2;
        _resumptionSecret = resumptionSecret;
    }
    return self;
}

+ (NSData *)mmPost:(NSData *)mmtlsData withHost:(NSString *)headerHost
{
    time_t t = time(NULL);
    srand((unsigned int) t);
    unsigned long long r = rand();

    NSString *host = [NSString stringWithFormat:@"http://%@", @"58.247.204.139"];
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@", host, [NSString stringWithFormat:@"mmtls/%08llx", r]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstr]];
    [request addRequestHeader:@"Accept" value:@"*/*"];
    [request addRequestHeader:@"Cache-Control" value:@"no-cache"];
    [request addRequestHeader:@"Connection" value:@"close"];
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [request addRequestHeader:@"Host" value:headerHost];
    [request addRequestHeader:@"User-Agent" value:@"MicroMessenger Client"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", [mmtlsData length]]];
    [request addRequestHeader:@"Upgrade" value:@"mmtls"];

    [request setAllowCompressedResponse:NO];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[mmtlsData mutableCopy]];

    [request startSynchronous];

    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
    }

    return [request responseData];
}

+ (NSData *)getPayloadDataWithData:(NSData *)shortlinkData
                           cgiPath:(NSString *)cgiPath
                              host:(NSString *)host
{
    NSData *cgiPathLen = [NSData packInt16:[cgiPath length] flip:YES];
    NSData *shortlinkDataLen = [NSData packInt32:(int32_t)[shortlinkData length] flip:YES];
    NSData *payloadData = [cgiPathLen addDataAtTail:[cgiPath dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *hostLen = [NSData packInt16:[host length] flip:YES];
    payloadData = [payloadData addDataAtTail:hostLen];
    payloadData = [payloadData addDataAtTail:[host dataUsingEncoding:NSUTF8StringEncoding]];

    payloadData = [payloadData addDataAtTail:shortlinkDataLen];
    payloadData = [payloadData addDataAtTail:shortlinkData];

    NSData *len4 = [NSData packInt32:(int32_t)[payloadData length] flip:YES];
    payloadData = [len4 addDataAtTail:payloadData];

    return payloadData;
}

+ (NSData *)post:(NSData *)sendData toCgiPath:(NSString *)cgiPath
{
    NSData *httpPayloadData =
        [ShortLinkClientWithMMTLS getPayloadDataWithData:sendData
                                                 cgiPath:cgiPath
                                                    host:@"szextshort.weixin.qq.com"];

    ShortLinkWithMMTLS *slm =
        [[ShortLinkWithMMTLS alloc] initWithDecryptedPart2:[DBManager sharedManager].shortLinkPSKData
                                          resumptionSecret:[DBManager sharedManager].resumptionSecret
                                                  httpData:httpPayloadData];

    NSData *mmtlsData = [slm getSendData];
    NSData *httpResponseBody = [ShortLinkClientWithMMTLS mmPost:mmtlsData withHost:@"szextshort.weixin.qq.com"];

    LogInfo(@"httpPayloadData Data HexDump: \n\n%@", httpPayloadData.hexDump);
    LogInfo(@"Send Data HexDump: \n\n%@", mmtlsData.hexDump);
    LogInfo(@"Rcv Data HexDump: \n\n%@", httpResponseBody.hexDump);

    MMTLSShortLinkResponse *response = [[MMTLSShortLinkResponse alloc] initWithData:httpResponseBody];
    NSData *packData = [slm receiveData:response];

    LogInfo(@"ShortLink PackedData HexDump: \n\n%@", packData.hexDump);

    return packData;
}

@end
