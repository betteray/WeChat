//
//  PersonalInfoService.m
//  WeChat
//
//  Created by ray on 2019/10/14.
//  Copyright © 2019 ray. All rights reserved.
//

#import "PersonalInfoService.h"
#import "Mm.pbobjc.h"
#import "FSOpenSSL.h"
#import "WCContact.h"


@implementation PersonalInfoService

+ (void)getprofile
{
    GetProfileRequest *request = [GetProfileRequest new];
    request.userName = @"";
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 118;
    cgiWrap.cgi = 302;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/getprofile";
    cgiWrap.responseClass = [GetProfileResponse class];
    
    [WeChatClient startRequest:cgiWrap
                      success:^(GetProfileResponse *_Nullable response) {
                        
        LogDebug(@"%@", response);
        
        NSString *getProfileResponsePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GetProfileResponse.bin"];
        [[response data] writeToFile:getProfileResponsePath atomically:YES];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [WCContact createOrUpdateInDefaultRealmWithValue:@[response.userInfo.userName.string,
                                                         response.userInfo.nickName.string,
                                                         response.userInfo.province,
                                                         response.userInfo.city,
                                                         response.userInfo.signature,
                                                         @"",
                                                         response.userInfoExt.bigHeadImgURL,
                                                         response.userInfoExt.smallHeadImgURL]];
        [realm commitWriteTransaction];
                      }
                      failure:^(NSError *_Nonnull error){
                          
                      }];
}

- (void)uploadHeadImg { // test OK
    UploadHDHeadImgRequest *reqeust = [UploadHDHeadImgRequest new];

    NSData *headImageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"head" ofType:@"jpg"]];
    NSMutableData *headImageDataHash = [[FSOpenSSL md5DataFromData:headImageData] mutableCopy];

    NSString *ts = [NSString stringWithFormat:@"%lu", time(0)];
    [headImageDataHash appendData:[ts dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *imgHash = [FSOpenSSL md5DataFromData:headImageDataHash];
    reqeust.imgHash = [[NSString alloc] initWithData:imgHash encoding:NSUTF8StringEncoding];

    [reqeust setHeadImgType:1];
    [reqeust setTotalLen:(int32_t) [headImageData length]];
    [reqeust setStartPos:0];
    [reqeust setUserName:@""];
    SKBuiltinBuffer_t *pData = [[SKBuiltinBuffer_t alloc] init];
    pData.iLen = (int32_t) [headImageData length];
    pData.buffer = headImageData;
    [reqeust setData_p:pData];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 157;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadhdheadimg";
    cgiWrap.request = reqeust;
    cgiWrap.responseClass = [UploadHDHeadImgResponse class];
    cgiWrap.needSetBaseRequest = YES;

    [WeChatClient postRequest:cgiWrap success:^(CliReportKVResp * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

+ (void)updateNickNameOrSignature {
    OplogRequest *req = [[OplogRequest alloc] init];
    CmdItem *item = [CmdItem new];
    item.cmdId = 64; // 对应 ModSingleField
    
    ModSingleField *modSingleField = [ModSingleField new];
    [modSingleField setOpType:1];   // 1，昵称。 2，签名
    [modSingleField setValue:@"蓝柿子1"];
    
    NSData *cmdBuffer = [modSingleField data];
    
    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t new];
    buffer.iLen = (int32_t) [cmdBuffer length];
    buffer.buffer = cmdBuffer;
    
    item.cmdBuf = buffer;
    
    CmdList *cmdList = [CmdList new];
    cmdList.count = 1;
    cmdList.listArray = [@[item] mutableCopy];
    
    req.oplog = cmdList;
    
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 681;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/oplog";
    cgiWrap.request = req;
    cgiWrap.responseClass = [OplogResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(OplogResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

+ (void)updateGenderOrRegion {
    OplogRequest *req = [[OplogRequest alloc] init];
    CmdItem *item = [CmdItem new];
    item.cmdId = 1; // 对应 ModUserInfo
    
    NSString *getProfileResponsePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GetProfileResponse.bin"];
    NSData *getProfileResponseData = [NSData dataWithContentsOfFile:getProfileResponsePath];
    GetProfileResponse *resp = [GetProfileResponse parseFromData:getProfileResponseData error:nil];
    
    ModUserInfo *modUserInfo = [ModUserInfo new];
    
    //mmregion4client_en.txt
    //en|CA_Alberta|Alberta
    [modUserInfo setBitFlag:resp.userInfo.bitFlag];
    [modUserInfo setUserName:resp.userInfo.userName];
    [modUserInfo setNickName:resp.userInfo.nickName];
    [modUserInfo setBindUin:resp.userInfo.bindUin];
    [modUserInfo setBindEmail:resp.userInfo.bindEmail];
    [modUserInfo setBindMobile:resp.userInfo.bindMobile];
    [modUserInfo setStatus:resp.userInfo.status];
    [modUserInfo setImgLen:resp.userInfo.imgLen];
    [modUserInfo setSex:2];
    [modUserInfo setProvince:@"Alberta"];
    [modUserInfo setCity:resp.userInfo.city];
    [modUserInfo setSignature:resp.userInfo.signature];
    [modUserInfo setPersonalCard:resp.userInfo.personalCard];
    [modUserInfo setPluginFlag:resp.userInfo.pluginFlag];
    [modUserInfo setCountry:@"CA"];
    
    NSData *cmdBuffer = [modUserInfo data];
    
    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t new];
    buffer.iLen = (int32_t) [cmdBuffer length];
    buffer.buffer = cmdBuffer;
    
    item.cmdBuf = buffer;
    
    CmdList *cmdList = [CmdList new];
    cmdList.count = 1;
    cmdList.listArray = [@[item] mutableCopy];
    
    req.oplog = cmdList;
    
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 681;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/oplog";
    cgiWrap.request = req;
    cgiWrap.responseClass = [OplogResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(OplogResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

+ (void)testOpLog {
    //OplogRequest请求，下方的数据可以由此构造。
//    Json: {"oplog":{"count":1,"list":[{"cmdId":1,"cmdBuf":{"iLen":153,"buffer":"<08821112 150a1377 7869645f 33307568 64736b6b 6c796369 32321a11 0a0fe893 9de69fbf e5ad90e5 9388e593 8820002a 020a0032 020a0038 a1a00e40 0050015a 0062006a 48e4baba e7949fe9 8193e8b7 afe4b88a e79a84e6 af8fe4b8 80e4b8aa e9878ce7 a88be7a2 91efbc8c e983bde5 88bbe79d 80e4b8a4 e4b8aae5 ad97e280 9ce8b5b7 e782b9e2 809de380 82700180 01a1f109 b2020243 4e>"}}]}}
//    SerializedData: <0aa90108 0112a401 0801129f 01089901 12990108 82111215 0a137778 69645f33 30756864 736b6b6c 79636932 321a110a 0fe8939d e69fbfe5 ad90e593 88e59388 20002a02 0a003202 0a0038a1 a00e4000 50015a00 62006a48 e4babae7 949fe981 93e8b7af e4b88ae7 9a84e6af 8fe4b880 e4b8aae9 878ce7a8 8be7a291 efbc8ce9 83bde588 bbe79d80 e4b8a4e4 b8aae5ad 97e2809c e8b5b7e7 82b9e280 9de38082 70018001 a1f109b2 0202434e>

    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"region" ofType:@"bin"]];
    OplogRequest *request = [[OplogRequest alloc] initWithData:data error:nil];
    CmdList *cmdList = request.oplog;
    CmdItem *cmdItem = cmdList.listArray[0];
    ModUserInfo *modSingleField = [[ModUserInfo alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];

    LogVerbose(@"cmdID: %d, %@", cmdItem.cmdId, modSingleField);
}

@end
