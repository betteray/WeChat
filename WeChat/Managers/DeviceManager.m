//
//  DeviceManager.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DeviceManager.h"

@interface DeviceManager ()
@property (nonatomic, strong) WCDevice *sevenPuls;
@property (nonatomic, strong) WCDevice *mi3;
@end

@implementation DeviceManager

+ (instancetype)sharedManager
{
    static DeviceManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });

    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *imei = @"8fd2fc510d3fb9bb8e0661b0c6a026cc";
        NSString *ts = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        NSString *adSource = @"15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35";

        NSString *sofyType = [NSString stringWithFormat:@"<softtype>"
                                                         "<k3>11.3.1</k3>"
                                                         "<k9>iPhone</k9>"
                                                         "<k10>2</k10>"
                                                         "<k19>16F3CF44-DC31-4038-A219-3111C3F71FA8</k19>"
                                                         "<k20>%@</k20>"
                                                         "<k22>中国移动</k22>"
                                                         "<k33>微信</k33>"
                                                         "<k47>1</k47>"
                                                         "<k50>1</k50>"
                                                         "<k51>com.tencent.xin</k51>"
                                                         "<k54>iPhone9,2</k54>"
                                                         "<k61>2</k61>"
                                                         "</softtype>", adSource];

        WCDevice *sevenPuls = [[WCDevice alloc] initWithImei:imei
                                                    softType:sofyType
                                                   clientSeq:[NSString stringWithFormat:@"%@-%@", imei, ts]
                                                  deviceName:@"cdg iPhone"
                                                  deviceType:@"iPhone"
                                                    language:@"zh_CN"
                                                    timeZone:@"8.00"
                                                 deviceBrand:@"Apple"
                                                      chanel:0
                                                 realCountry:@"CN"
                                                    bundleID:@"com.tencent.xin"
                                                   iphoneVer:@"iPhone9,2"
                                                      osType:@""
                                                    adSource:adSource
                                                 deviceModle:@""
                                                    deviceID:@"49D2FC510D3FB9BB8E0661B0C6A026CC"];

        _sevenPuls = sevenPuls;
    }

    return self;
}

- (WCDevice *)getCurrentDevice
{
    return _sevenPuls;
}


@end
