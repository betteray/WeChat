//
//  DeviceManager.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DeviceManager.h"

@interface DeviceManager ()

@property (nonatomic, strong) WCDevice *curDevice;

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
        // 从dump出来的proto中恢复设备参数用以登录。
        // ClientSpamInfo *clientSpamInfo = [ClientSpamInfo parseFromData:stProtoData error:nil];
        // mi4.clientSpamInfo = clientSpamInfo;
        // NSData *fpData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mi4-fp" ofType:@"bin"]];
        // FPDevice *fp = [FPDevice parseFromData:fpData error:nil];
        
        // 添加设备，从导出的json格式数据中恢复设备。
        NSData *onlineDeviceJsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"online" ofType:@"json"]];
        NSDictionary *onlineDeviceJson = [NSJSONSerialization JSONObjectWithData:onlineDeviceJsonData options:0 error:nil];
        WCDevice *onlineDevice = [WCDevice deviceFromJson:onlineDeviceJson];
        
        _curDevice = onlineDevice;
        if (![DBManager autoAuthKey].data.length) { // 如果数据库中没有autoauthkey，则导入数据，保证只导入一次。
            [self importDBData:_curDevice]; //每个json文件只能导入一次，否则会覆盖数据库最新数据。
        }
    }

    return self;
}

- (WCDevice *)getCurrentDevice
{
#if PROTOCOL_FOR_IOS
    return _sevenPuls;
#elif PROTOCOL_FOR_ANDROID
    return _curDevice;
#endif
}

- (void)importDBData:(WCDevice *)device {
    [DBManager saveAutoAuthKey:[NSData dataWithHexString:device.autoAuthkeyHex]];
    [DBManager saveCookie:[NSData dataWithHexString:device.cookieHex]];
    [DBManager saveSyncKey:[NSData dataWithHexString:device.syncKeyHex]];
    [DBManager saveAccountInfo:device.uin userName:device.username nickName:@"" alias:@""];
}

@end
