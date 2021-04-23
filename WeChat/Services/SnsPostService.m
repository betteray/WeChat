//
//  SnsPostService.m
//  WeChat
//
//  Created by ray on 2019/12/27.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SnsPostService.h"
#import "FSOpenSSL.h"
#import "WCSafeSDK.h"

@implementation SnsPostService

+ (void)startSendSNSPost:(NSArray *)cdnResponse {
    SnsPostRequest *request = [SnsPostRequest new];
    
    NSData *xmlData = [self getObjectDesc:cdnResponse];
    SKBuiltinBuffer_t *objectDesc = [SKBuiltinBuffer_t new];
    objectDesc.iLen = (uint32_t)xmlData.length;
    objectDesc.buffer  = xmlData;
    request.objectDesc = objectDesc;

    request.withUserListCount = 0;
    request.privacy = 0;
    request.syncFlag = 0;
    NSString *clientId = [FSOpenSSL md5StringFromString:[NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate date] timeIntervalSince1970]]];
    request.clientId = clientId;
    request.postBgimgType = 1;
    request.groupCount = 0;
    request.objectSource = 0;
    request.referId = 0;
    request.blackListCount = 0;
    request.groupUserCount = 0;
    SnsPostOperationFields *snsPostOperationFields = [SnsPostOperationFields new];
//        snsPostOperationFields.shareURLOriginal = @"";
//        snsPostOperationFields.shareURLOpen = @"";
//        snsPostOperationFields.jsAppId = @"";
    snsPostOperationFields.contactTagCount = 0;
    snsPostOperationFields.tempUserCount = 0;

    request.snsPostOperationFields = snsPostOperationFields;
    SKBuiltinBuffer_t *poiInfo = [SKBuiltinBuffer_t new];
    poiInfo.iLen = 0;
    poiInfo.buffer = [NSData data];
    request.poiInfo = poiInfo;

    request.fromScene = @"";
    
    uint32_t startTime =  (uint32_t) [[NSDate date] timeIntervalSince1970];
    NSMutableArray *ma = [NSMutableArray array];
    int i = (int) [cdnResponse count];
    while (i--) {
        MediaInfo *mediaInfo = [MediaInfo new];
        mediaInfo.videoPlayLength = 0;
        mediaInfo.mediaType = 1;
        mediaInfo.source = 2;
        mediaInfo.sessionId = [NSString stringWithFormat:@"memonts-%ld", (NSInteger) [[NSDate date] timeIntervalSince1970]];
        mediaInfo.startTime = startTime;
        [ma addObject:mediaInfo];
    }
    
    request.mediaInfoCount = (uint32_t) [ma count];
    request.mediaInfoArray = ma;
    
    NSData *extSpamInfoBuffer = [WCSafeSDK getExtSpamInfoWithContent:nil context:@"&lt;SNSPost&gt"];
    request.extSpamInfo = [WCExtInfo2 parseFromData:extSpamInfoBuffer error:nil];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 209;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/mmsnspost";
    cgiWrap.responseClass = [SnsPostResponse class];

    [WeChatClient postRequest:cgiWrap
                      success:^(SnsPostResponse *_Nullable response) {
                          LogVerbose(@"SnsPostResponse: %@", response);
                      }
                      failure:^(NSError *_Nonnull error){

                      }];
}

+ (NSData *)getObjectDesc:(NSArray *)cdnResponse {
    
    NSMutableString *ms = [NSMutableString new];
    for (NSDictionary *res in cdnResponse) {
        NSString *mediaFormat = @"<media>"
                                    "<id>0</id>"
                                    "<type>2</type>"
                                    "<title></title>"
                                    "<description></description>"
                                    "<private>0</private>"
                                    "<userData></userData>"
                                    "<subType>0</subType>"
                                    "<videoSize width=\"795\" height=\"1413\"/>"
                                    "<url type=\"1\" md5=\"%@\" videomd5=\"\" >%@</url>" //url 0
                                    "<thumb type=\"1\">%@</thumb>" // url 150
                                    "<size width=\"795.000000\" height = \"1413.000000\" totalSize=\"0\"/>"
                                "</media>";
        NSString *media = [NSString stringWithFormat:mediaFormat,
                                               [res objectForKey:@"filekey"],
                                               [res objectForKey:@"fileurl"],
                                               [res objectForKey:@"thumburl"]];
        [ms appendString:media];
    }
    
    NSString *xml =
    @"<TimelineObject> "
        "<id>0</id>"
        "<username>%@</username>" // wxid_30uhdskklyci22
        "<createTime>%@</createTime>" // 1575448220
        "<contentDesc></contentDesc>"
        "<contentDescShowType>0</contentDescShowType>"
        "<contentDescScene>3</contentDescScene>"
        "<private>0</private>"
        "<sightFolded>0</sightFolded>"
        "<showFlag>0</showFlag>"
        "<appInfo>"
            "<id></id>"
            "<version></version>"
            "<appName></appName>"
            "<installUrl></installUrl>"
            "<fromUrl></fromUrl>"
            "<isForceUpdate>0</isForceUpdate>"
        "</appInfo>"
        "<sourceUserName></sourceUserName>"
        "<sourceNickName></sourceNickName>"
        "<statisticsData></statisticsData>"
        "<statExtStr></statExtStr>"
        "<ContentObject>"
            "<contentStyle>1</contentStyle>"
            "<title></title>"
            "<description></description>"
            "<mediaList>"
                "%@"
            "</mediaList>"
        "</ContentObject>"
    "</TimelineObject>";
    
    AccountInfo *accountInfo = [DBManager accountInfo];
    NSString *picXml = [NSString stringWithFormat:xml,
                        accountInfo.userName,
                        [NSString stringWithFormat:@"%ld", (NSUInteger) [[NSDate date] timeIntervalSince1970]],
                        [ms copy]];
    return [picXml dataUsingEncoding:NSUTF8StringEncoding];
}

@end
