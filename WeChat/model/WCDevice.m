//
//  Device.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WCDevice.h"

@interface WCDevice()

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
@property (nonatomic, copy) NSString *osType;
@property (nonatomic, copy) NSString *adSource;
@property (nonatomic, copy) NSString *deviceModle;
@property (nonatomic, copy) NSString *deviceID;

@end

@implementation WCDevice

- (instancetype)initWithImei:(NSString *)imei
                    softType:(NSString *)softType
                   clientSeq:(NSString *)clientSeq
                  deviceName:(NSString *)deviceName
                  deviceType:(NSString *)deviceType
                    language:(NSString *)language
                    timeZone:(NSString *)timeZone
                 deviceBrand:(NSString *)deviceBrand
                      chanel:(NSInteger)chanel
                 realCountry:(NSString *)realCountry
                    bundleID:(NSString *)bundleID
                   iphoneVer:(NSString *)iphoneVer
                      osType:(NSString *)osType
                    adSource:(NSString *)adSource
                 deviceModle:(NSString *)deviceModel
                    deviceID:(NSString *)deviceID
{
    self  = [super init];
    if (self) {
        _imei = imei;
        _softType = softType;
        _clientSeq = clientSeq;
        _deviceName = deviceName;
        _deviceType = deviceType;
        _language = language;
        _timeZone = timeZone;
        _deviceBrand = deviceBrand;
        _chanel = chanel;
        _realCountry = realCountry;
        _bundleID = bundleID;
        _iphoneVer = iphoneVer;
        _osType = osType;
        _adSource = adSource;
        _deviceModle = deviceModel;
        _deviceID = deviceID;
    }
    
    return self;
}

@end
