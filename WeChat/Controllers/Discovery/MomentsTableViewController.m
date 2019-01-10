//
//  MomentsTableViewController.m
//  WeChat
//
//  Created by ray on 2019/1/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MomentsTableViewController.h"
#import "FSOpenSSL.h"

@interface MomentsTableViewController ()

@end

@implementation MomentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchSnsTimeLine];
}

- (IBAction)sendSnsPostRequest:(id)sender {
    SnsPostRequest *request = [SnsPostRequest new];
    NSString *xml = @"<TimelineObject><id>0</id><username>wxid_hbd318lqsskq22</username><createTime>1547105885</createTime><contentDesc>hello world</contentDesc><contentDescShowType>0</contentDescShowType><contentDescScene>3</contentDescScene><private>0</private><sightFolded>0</sightFolded><showFlag>0</showFlag><appInfo><id></id><version></version><appName></appName><installUrl></installUrl><fromUrl></fromUrl><isForceUpdate>0</isForceUpdate></appInfo><sourceUserName></sourceUserName><sourceNickName></sourceNickName><statisticsData></statisticsData><statExtStr></statExtStr><ContentObject><contentStyle>2</contentStyle><title></title><description></description><mediaList></mediaList></ContentObject></TimelineObject>";
    NSData *xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    SKBuiltinBuffer_t *objectDesc = [SKBuiltinBuffer_t new];
    objectDesc.iLen = (uint32_t)xmlData.length;
    objectDesc.buffer  = xmlData;
    request.objectDesc = objectDesc;
    
    request.withUserListCount = 0;
    request.privacy = 0;
    request.syncFlag = 0;
    NSString *clientId = [FSOpenSSL md5FromString:[NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate date] timeIntervalSince1970]]];
    request.clientId = clientId;
    request.postBgimgType = 0;
    request.groupCount = 0;
    request.objectSource = 0;
    request.referId = 0;
    request.blackListCount = 0;
    request.groupUserCount = 0;
    SnsPostOperationFields *snsPostOperationFields = [SnsPostOperationFields new];
    snsPostOperationFields.shareURLOriginal = @"";
    snsPostOperationFields.shareURLOpen = @"";
    snsPostOperationFields.jsAppId = @"";
    snsPostOperationFields.contactTagCount = 0;
    snsPostOperationFields.tempUserCount = 0;
    
    request.snsPostOperationFields = snsPostOperationFields;
    SKBuiltinBuffer_t *poiInfo = [SKBuiltinBuffer_t new];
    poiInfo.iLen = 0;
    poiInfo.buffer = [NSData data];
    request.poiInfo = poiInfo;
    
    request.fromScene = @"";
    request.mediaInfoCount = 0;
    
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
