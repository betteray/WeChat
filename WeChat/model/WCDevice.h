//
//  Device.h
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCDevice : NSObject

@property (nonatomic, readonly, copy) NSString *imei;
@property (nonatomic, readonly, copy) NSString *softType;
@property (nonatomic, readonly, copy) NSString *clientSeq;
@property (nonatomic, readonly, copy) NSString *clientSeqIdsign;
@property (nonatomic, readonly, copy) NSString *deviceName;
@property (nonatomic, readonly, copy) NSString *deviceType;
@property (nonatomic, readonly, copy) NSString *language;
@property (nonatomic, readonly, copy) NSString *timeZone;
@property (nonatomic, readonly, copy) NSString *deviceBrand;
@property (nonatomic, readonly, assign) NSInteger chanel;
@property (nonatomic, readonly, copy) NSString *realCountry;
@property (nonatomic, readonly, copy) NSString *bundleID;
@property (nonatomic, readonly, copy) NSString *iphoneVer;
@property (nonatomic, readonly, copy) NSString *osType;
@property (nonatomic, readonly, copy) NSString *adSource;
@property (nonatomic, readonly, copy) NSString *deviceModel;
@property (nonatomic, readonly, strong) NSData *deviceID;

- (instancetype)initWithImei:(NSString *)imei
                    softType:(NSString *)softType
                   clientSeq:(NSString *)clientSeq
             clientSeqIdsign:(NSString *)clientSeqIdsign
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
                 deviceModel:(NSString *)deviceModel
                    deviceID:(NSString *)deviceID;

@end
