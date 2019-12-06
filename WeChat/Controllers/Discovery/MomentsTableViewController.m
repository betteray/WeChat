//
//  MomentsTableViewController.m
//  WeChat
//
//  Created by ray on 2019/1/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MomentsTableViewController.h"
#import "FSOpenSSL.h"
#import "CdnLogic.h"
#import "WCSafeSDK.h"

@interface MomentsTableViewController ()

@end

@implementation MomentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self fetchSnsTimeLine];
}

- (IBAction)sendSnsPostRequest:(id)sender {
    NSString *pic = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    //    response
    //    {
    //        enablequic = 0;
    //        filekey = a019d837919cd0245cd950f5d54e65d5;
    //        fileurl = "http://shmmsns.qpic.cn/mmsns/O5IB5rptd1qib8b8Izmpr4SxJe1IbnFzpGcDT8tsGbaicAurMwncp85X1tPEicBYJDywz7ejNLoxu4/0";
    //        isgetcdn = 0;
    //        isoverload = 0;
    //        isretry = 0;
    //        recvlen = 17469;
    //        retcode = 0;
    //        retrysec = 0;
    //        seq = 1;
    //        thumburl = "http://shmmsns.qpic.cn/mmsns/O5IB5rptd1qib8b8Izmpr4SxJe1IbnFzpGcDT8tsGbaicAurMwncp85X1tPEicBYJDywz7ejNLoxu4/150";
    //        ver = 0;
    //        "x-ClientIp" = "43.243.12.74";
    //    }
    
    [[CdnLogic new] startC2CUpload:pic success:^(NSDictionary *  _Nullable response) {
        LogVerbose(@"上传朋友圈图片 response： %@", response);
        
        AccountInfo *accountInfo = [DBManager accountInfo];
        
        SnsPostRequest *request = [SnsPostRequest new];
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
                    "<media>"
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
                    "</media>"
                "</mediaList>"
            "</ContentObject>"
        "</TimelineObject>";
        
        NSString *picXml = [NSString stringWithFormat:xml,
                            accountInfo.userName,
                            [NSString stringWithFormat:@"%ld", (NSUInteger) [[NSDate date] timeIntervalSince1970]],
                            [response objectForKey:@"filekey"],
                            [response objectForKey:@"fileurl"],
                            [response objectForKey:@"thumburl"]
                            ];
        NSData *xmlData = [picXml dataUsingEncoding:NSUTF8StringEncoding];
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
        request.mediaInfoCount = 1;
        MediaInfo *mediaInfo = [MediaInfo new];
        mediaInfo.videoPlayLength = 0;
        mediaInfo.mediaType = 1;
        mediaInfo.source = 1;
        mediaInfo.sessionId = [NSString stringWithFormat:@"memonts-%ld", (NSInteger) [[NSDate date] timeIntervalSince1970]];
        mediaInfo.startTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
        request.mediaInfoArray = [@[mediaInfo] mutableCopy];
        
//        if (CLIENT_VERSION > A703) {
//            NSData *extSpamInfoBuffer = [WCSafeSDK getextSpamInfoBufferWithContent:self.userNameTextField.text context:@"&lt;LoginByID&gt"];
//
//            SKBuiltinBuffer_t *extSpamInfo = [SKBuiltinBuffer_t new];
//            extSpamInfo.iLen = (int32_t) [extSpamInfoBuffer length];
//            extSpamInfo.buffer = extSpamInfoBuffer;
//
//            request.extSpamInfo = extSpamInfo; // tag=24
//        }
        
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
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    

    
}

- (void)fetchSnsTimeLine
{
    SnsTimeLineRequest *request = [SnsTimeLineRequest new];
    request.firstPageMd5 = @"";
    request.minFilterId = 0;
    request.maxId = 0;
    request.lastRequestTime = 0;
    request.clientLatestId = 0;
    request.networkType = 1;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 211;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/mmsnstimeline";
    cgiWrap.responseClass = [SnsTimeLineResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(SnsTimeLineResponse *_Nullable response) {
                          LogVerbose(@"SnsTimeLine Resp: %@", response);
                      }
                      failure:^(NSError *_Nonnull error){
                          
                      }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

@end
