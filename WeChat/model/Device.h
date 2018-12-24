//
//  Device.h
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, readonly, copy) NSString *imei;
@property (nonatomic, readonly, copy) NSString *softType;
@property (nonatomic, readonly, copy) NSString *clientSeq;
@property (nonatomic, readonly, copy) NSString *deviceName;
@property (nonatomic, readonly, copy) NSString *deviceType;
@property (nonatomic, readonly, copy) NSString *language;
@property (nonatomic, readonly, copy) NSString *timeZone;
@property (nonatomic, readonly, copy) NSString *deviceBrand;
@property (nonatomic, readonly, assign) NSInteger chanel;
@property (nonatomic, readonly, copy) NSString *realCountry;
@property (nonatomic, readonly, copy) NSString *bundleID;
@property (nonatomic, readonly, copy) NSString *iphoneVer;
@property (nonatomic, readonly, copy) NSString *adSource;
@property (nonatomic, readonly, copy) NSString *deviceModle;
@property (nonatomic, readonly, copy) NSString *deviceID;

@end
