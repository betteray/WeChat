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
@property (nonatomic, readonly, copy) NSData *osType;
@property (nonatomic, readonly, copy) NSString *adSource;
@property (nonatomic, readonly, copy) NSString *deviceModel;
@property (nonatomic, readonly, strong) NSData *deviceID;

// nullable
@property (nonatomic, readonly, strong) NSString *autoAuthkeyHex;
@property (nonatomic, readonly, strong) NSString *cookieHex;
@property (nonatomic, readonly, strong) NSString *syncKeyHex;
@property (nonatomic, readonly, assign) uint32_t uin;
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, strong) FPDevice *fpDevice;
@property (nonatomic, readonly, strong) ClientSpamInfo *clientSpamInfo;

+ (instancetype)deviceWithManualAuth:(ManualAuthRequest *)manualAuthRequet
                      clientSpamInfo:(ClientSpamInfo *)clientSpamInfo
                            fpDevice:(FPDevice *)fpDevice;
- (instancetype)initWithManualAuth:(ManualAuthRequest *)manualAuthRequet
                    clientSpamInfo:(ClientSpamInfo *)clientSpamInfo
                          fpDevice:(FPDevice *)fpDevice;

+ (instancetype)deviceFromJson:(NSDictionary *)jsonDict;
- (instancetype)initWithJson:(NSDictionary *)jsonDict;

- (NSDictionary *)toDictionary;

@end
