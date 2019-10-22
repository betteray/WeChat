//
//  WCSafeSDK.m
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import "WCSafeSDK.h"
#import "NSData+CRC32.h"
#import "ASIHTTPRequest.h"
#include <sys/time.h>

@implementation WCSafeSDK

+ (NSData *)get003FromLocalServer:(NSString *)xml {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8099"]];
    request.postBody = (NSMutableData *)[xml dataUsingEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
        return [NSData new];
    }
    
    return [request responseData];
}

+ (NSString *)genST:(int)a {
    NSString *resName = nil;
    switch (a) {
        case 0:
            resName = @"st-6p-login";
            break;
        case 15:
            resName = @"st-6p-clientcheck";
            break;
        default:
            break;
    }
    
    NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resName ofType:@"bin"]];
    NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdcc>714570694</ccdcc>" withString:@""];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdts>1571129457</ccdts>" withString:@""];
    
    NSString *versionXML = [NSString stringWithFormat:@"<ClientVersion>0x%x</ClientVersion>", CLIENT_VERSION];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ClientVersion>0x27000634</ClientVersion>" withString:versionXML];
    
    uint32_t crc32Result = [[xml dataUsingEncoding:NSUTF8StringEncoding] crc32];
    return [NSString stringWithFormat:@"%@<ccdcc>%d</ccdcc><ccdts>%ld</ccdts>", xml, crc32Result, time(0)];
}

+ (void)reportClientCheckWithContext:(uint64_t)context {
    
    NSString *xml = [self genST:15];
    NSData *encrypedXMLBuffer = [self get003FromLocalServer:xml];
    
    ReportClientCheckReq *req = [[ReportClientCheckReq alloc] init];
    req.encryptedXmlbuffer = encrypedXMLBuffer;
    req.reportContext = context;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 771;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/reportclientcheck";
    cgiWrap.request = req;
    cgiWrap.responseClass = [ReportClientCheckResp class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(ReportClientCheckResp * _Nullable response) {
        LogVerbose(@"ReportClientCheckResp = %@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

static inline int getRandomSpan() {
    return arc4random()%3000 + 201;
}

+ (NSString *)genWCSTFWithAccount:(NSString *)account {
    
    // <WCSTF>
    // <st>1571129265349</st><et>1571129431323</et><cc>10</cc>
    // <ct>1571129265349,1571129265654,1571129269338,1571129269656,1571129269840,1571129274589,1571129274591,1571129275669,1571129276218,1571129276442</ct>
    // </WCSTF>
    
    // <ct>1571129265349,1571129265654,1571129269338,1571129269656,1571129269840,1571129274589,1571129274591,1571129275669,1571129276218,1571129276442</ct>
    //                 305          3684          318            184           4749
    
    int timeSpan[20] =
    {
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan()
    };
    
    struct timeval tp = {0};
    
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    long st = tp.tv_sec * 1000 + tp.tv_usec;
    
    long et = st;
    
    NSMutableString *string = [NSMutableString stringWithString:@"<ct>"];
    for (int i=0; i<account.length; i++) {
        st = st - timeSpan[arc4random()%20]; // 从此刻向前计算
        [string appendFormat:@"%ld,", et];
    }
    st = st - timeSpan[arc4random()%20]; // 从此刻向前计算
    
    NSString *ctXML = [string substringToIndex:string.length-2];
    ctXML = [NSString stringWithFormat:@"%@</ct>", ctXML];
    
    return [NSString stringWithFormat:@"<WCSTF><st>%ld</st><et>%ld</et><cc>%ld</cc>%@</WCSTF>", st, et, [account length], ctXML];
}

+ (NSString *)genWCSTEWithContext:(NSString *)context {
    
    struct timeval tp = {0};
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    
    return [NSString stringWithFormat:@"<WCSTE><context>%@</context><st>0</st><et>%d</et><iec>0</iec><tec>1</tec><asst>0</asst><pss>384283711954223104</pss><tlmj>1154333283175126352</tlmj><tlmn>1154333283175126352</tlmn><thmj>1154333283175126352</thmj><thmn>1154333283175126352</thmn><sz>382893930598912004</sz></WCSTE>",
    context,
    (int) tp.tv_sec];
}

+ (NSData *)getextSpamInfoBufferWithContent:(NSString *)content
                                    context:(NSString *)context {
    
    NSString *WCSTF = [self genWCSTFWithAccount:content];
    NSString *WCSTE = [self genWCSTEWithContext:context];
    NSString *ST = [self genST:0]; // 0 登录用
    
    NSData *WCSTFData = [self get003FromLocalServer:WCSTF];
    NSData *WCSTEData = [self get003FromLocalServer:WCSTE];
    NSData *STData = [self get003FromLocalServer:ST];
    
    WCExtInfo *extInfo = [WCExtInfo new];
    
    SKBuiltinBuffer_t *wcstf = [SKBuiltinBuffer_t new];
    wcstf.iLen = (int32_t) [WCSTFData length];
    wcstf.buffer = WCSTFData;
    
    extInfo.wcstf = wcstf;
    
    SKBuiltinBuffer_t *wcste = [SKBuiltinBuffer_t new];
    wcste.iLen = (int32_t) [WCSTEData length];
    wcste.buffer = WCSTEData;
    
    extInfo.wcste = wcste;
    
    SKBuiltinBuffer_t *ccData = [SKBuiltinBuffer_t new];
    ccData.iLen = (int32_t) [STData length];
    ccData.buffer = STData;
    
    extInfo.ccData = ccData;
    
    return [extInfo data];
}

@end
