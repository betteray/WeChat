//
//  Device.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "Device.h"

#define IMEI @"8fd2fc510d3fb9bb8e0661b0c6a026cc"
#define SOFT_TYPE @"<softtype><k3>11.3.1</k3><k9>iPhone</k9><k10>2</k10><k19>16F3CF44-DC31-4038-A219-3111C3F71FA8</k19><k20>15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35</k20><k22>中国移动</k22><k33>微信</k33><k47>1</k47><k50>1</k50><k51>com.tencent.xin</k51><k54>iPhone9,2</k54><k61>2</k61></softtype>"
#define CLIENT_SEQ_ID [NSString stringWithFormat:@"%@-%@", IMEI, TIMESTAMP]
#define DEVICEN_NAME @"cdg iPhone"
#define DEVICE_TYPE @"iOS11.3.1"
#define LANGUAGE @"zh_CN"
#define TIME_ZONE @"8.00"
#define DEVICE_BRAND @"Apple"
#define CHANEL 0
#define REAL_COUNTRY @"CN"
#define BUNDLE_ID @"com.tencent.xin"
#define IPHONE_VER @"iPhone9,2"
#define OS_TYPE @""
#define AD_SOURCE @"15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35"
#define DEVICE_MODLE @""
#define DEVICE_ID @"49D2FC510D3FB9BB8E0661B0C6A026CC"

@interface Device()

@property (nonatomic, copy) NSString *imei;
@property (nonatomic, copy) NSString *softType;
@property (nonatomic, copy) NSString *clientSeq;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, copy) NSString *deviceBrand;
@property (nonatomic, assign) NSInteger chanel;
@property (nonatomic, copy) NSString *realCountry;
@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *iphoneVer;
@property (nonatomic, copy) NSString *adSource;
@property (nonatomic, copy) NSString *deviceModle;
@property (nonatomic, copy) NSString *deviceID;

@end

@implementation Device

- (instancetype)init
{
    self  = [super init];
    if (self) {
        
    }
    
    return self;
}

@end
