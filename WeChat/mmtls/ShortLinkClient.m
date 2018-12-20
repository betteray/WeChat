//
//  ShortLink.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ShortLinkClient.h"
#import "DNSManager.h"
#import <ASIHTTPRequest.h>

@interface ShortLinkClient()

@property(nonatomic, strong) NSData *decryptedPart2;
@property(nonatomic, strong) NSData *resumptionSecret;

@end

@implementation ShortLinkClient

- (instancetype)initWithDecryptedPart2:(NSData *)decryptedPart2 resumptionSecret:(NSData *)resumptionSecret
{
    self = [super init];
    if (self) {
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

    NSString *host = [NSString stringWithFormat:@"http://%@", [[DNSManager sharedMgr] getShortLinkIp]];
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
    NSData *hostLen = [NSData packInt16:[host length] flip:YES];
    NSData *shortlinkDataLen = [NSData packInt32:(int32_t)[shortlinkData length] flip:YES];
    NSData *payloadData = [cgiPathLen addDataAtTail:[cgiPath dataUsingEncoding:NSUTF8StringEncoding]];
    
    payloadData = [payloadData addDataAtTail:hostLen];
    payloadData = [payloadData addDataAtTail:[host dataUsingEncoding:NSUTF8StringEncoding]];
    
    payloadData = [payloadData addDataAtTail:shortlinkDataLen];
    payloadData = [payloadData addDataAtTail:shortlinkData];

    NSData *len4 = [NSData packInt32:(int32_t)[payloadData length] flip:YES];
    payloadData = [len4 addDataAtTail:payloadData];

    return payloadData;
}

//+ (void)postRequest:(CgiWrap *)cgiWrap
//            success:(SuccessBlock)successBlock
//            failure:(FailureBlock)failureBlock
//{
//    
//    if (cgiWrap.needSetBaseRequest)
//    {
//        BaseRequest *base = [BaseRequest new];
//        NSData *sessionKey = [[DBManager sharedManager] getSessionKey];
//        [base setSessionKey:sessionKey];
//        [base setUin:(int32_t)[WXUserDefault getUIN]];
//        [base setScene:0]; // iMac 1
//        [base setClientVersion:CLIENT_VERSION];
//        [base setDeviceType:DEVICE_TYPE];
//        [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];
//
//        [[cgiWrap request] performSelector:@selector(setBaseRequest:) withObject:base];
//    }
//
//    LogInfo(@"Start Request: %@", cgiWrap.request);
//
//    NSData *serilizedData = [[cgiWrap request] data];
//    NSData *sendData = [short_pack pack:cgiWrap.cgi serilizedData:serilizedData type:5 uin:_uin cookie:_cookie];
//
//    NSData *decryptedPart2 = _mmtlsClient.shortLinkPSKData;
//    NSData *resumptionSecret = _mmtlsClient.resumptionSecret;
//
//    NSData *httpData = [ShortLinkClient getPayloadDataWithData:sendData cgiPath:cgiWrap.cgiPath host:@"short.weixin.qq.com"];
//    DLog(@"HttpData", httpData);
//
//    ShortLinkWithMMTLS *slm = [[ShortLinkWithMMTLS alloc] initWithDecryptedPart2:decryptedPart2 resumptionSecret:resumptionSecret httpData:httpData];
//    NSData *mmtlsData = [slm getSendData];
//
//    DLog(@"Send mmtlsData", mmtlsData);
//
//    NSData *rcvData = [ShortLinkClient mmPost:mmtlsData withHost:@"short.weixin.qq.com"];
//
//    DLog(@"RCV mmtlsData", rcvData);
//
//    MMTLSShortLinkResponse *response = [[MMTLSShortLinkResponse alloc] initWithData:rcvData];
//    NSData *packData = [slm receiveData:response];
//    [self UnPack:packData];
//
//    Task *task = [Task new];
//    task.sucBlock = successBlock;
//    task.failBlock = failureBlock;
//    task.cgiWrap = cgiWrap;
//    [_tasks addObject:task];
//}


@end
