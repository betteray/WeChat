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
#import "OplogService.h"


@implementation PersonalInfoService

+ (void)getprofileSuccess:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock
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
    
    [WeChatClient startRequest:cgiWrap success:^(id  _Nullable response) {
        [self saveDataWithResp:response];
        successBlock(response);
    } failure:failureBlock];
                      
}

+ (void)saveDataWithResp:(GetProfileResponse *)response {
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
    
    NSString *getProfileResponsePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"GetProfileResponse.bin"];
    [[response data] writeToFile:getProfileResponsePath atomically:YES];
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
    ModSingleField *modSingleField = [ModSingleField new];
    [modSingleField setOpType:1];   // 1，昵称。 2，签名
    [modSingleField setValue:@"蓝柿子1"];
    [OplogService oplogRequestWithCmdId:64 message:modSingleField];
}

+ (void)updateGenderOrRegion {
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
   
    [OplogService oplogRequestWithCmdId:1 message:modUserInfo];
}

@end
