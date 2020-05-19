
//  QueryMidService.m
//  WeChat
//
//  Created by ray on 2020/5/19.
//  Copyright © 2020 ray. All rights reserved.
//

#import "QueryMidService.h"

@implementation QueryMidService

+ (void)startRequest {
    
    QueryMidRequest *request = [QueryMidRequest new];
    request.tag1 = 1;
    request.json = @"[{\"ky\":\"AVF4T76RVR81\",\"et\":2,\"ts\":1590637132,\"si\":1590637132,\"mc\":\"02:00:00:00:00:00\",\"mid\":\"0\",\"ev\":{\"sr\":\"1080*1920\",\"av\":\"7.0.12\",\"ch\":\"WX\",\"mf\":\"Xiaomi\",\"sv\":\"2.21\",\"ov\":\"29\",\"os\":1,\"lg\":\"zh\",\"md\":\"MI 4LTE\",\"tz\":\"Asia\\/Shanghai\",\"sd\":\"12010\\/13363\",\"apn\":\"com.tencent.mm\",\"wf\":\"{\\\"bs\\\":\\\"02:00:00:00:00:00\\\",\\\"ss\\\":\\\"<unknown ssid>\\\"}\",\"rom\":\"12010\\/13363\",\"cn\":\"WIFI\",\"tn\":0}}]";
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 684;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/querymid";
    
    cgiWrap.request = request;
    cgiWrap.responseClass = [QueryMidResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(QueryMidResponse *  _Nullable response) {
        if (response.baseResponse.ret == 0) {
            LogVerbose(@"QueriMid Suc!!!");
        } else {
            LogVerbose(@"QueriMid failed!!!");
        }
    } failure:^(NSError * _Nonnull error) {
        LogVerbose(@"QueriMid failed: %@", error);
    }];
    
}

@end

// [
//     {
//         "ky": "AVF4T76RVR81",   // 固定
//         "et": 2,                // 固定
//         "ts": 1590491348,       // 等于当前时间
//         "si": 1590491348,       // 等于当前时间
//         "mc": "02:00:00:00:00:00",
//         "mid": "0",              // ？没见到有值的情况
//         "ev": {
//             "sr": "1080*1920",
//             "av": "7.0.12",
//             "ch": "WX",
//             "mf": "Xiaomi",
//             "sv": "2.21",       // 固定
//             "ov": "29",
//             "os": 1,
//             "lg": "zh",
//             "md": "MI 4LTE",
//             "tz": "Asia\/Shanghai",
//             "sd": "11986\/13363",       //path = Environment.getExternalStorageDirectory().getPath() StatFs statFs = new StatFs(path);  str = // String.valueOf(String.valueOf((((long) statFs.getBlockSize()) * ((long) statFs.getAvailableBlocks())) / 1000000)) + "/" + String.valueOf((((long) // statFs.getBlockCount()) * ((long) statFs.getBlockSize())) / 1000000);
//             "apn": "com.tencent.mm",
//             "wf": "{\"bs\":\"02:00:00:00:00:00\",\"ss\":\"<unknown ssid>\"}",
//             "rom": "11986\/13363",      //StatFs statFs = new StatFs(Environment.getDataDirectory().getPath());  剩下的等于sd
//             "cn": "WIFI",
//             "tn": 0
//         }
//     }
// ]
