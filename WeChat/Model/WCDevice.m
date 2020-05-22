//
//  Device.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

//        NSString *k19 = @"856AA466-8098-4C90-9D6A-3EF6AFF6BC04"; //k19 = idfv
//        NSString *adSource = @"15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35"; //k20 = idfa

#import "WCDevice.h"

@interface WCDevice()

@property (nonatomic, copy) NSString *imei;
@property (nonatomic, copy) NSString *softType;
@property (nonatomic, copy) NSString *clientSeq;
@property (nonatomic, copy) NSString *clientSeqIdsign;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, copy) NSString *deviceBrand;
@property (nonatomic, assign) NSInteger chanel;
@property (nonatomic, copy) NSString *realCountry;
@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *iphoneVer;
@property (nonatomic, copy) NSData *osType;
@property (nonatomic, copy) NSString *adSource;
@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, strong) NSData *deviceID;

@end

@implementation WCDevice

+ (instancetype)deviceWithManualAuth:(ManualAuthRequest *)manualAuthRequet
                      clientSpamInfo:(ClientSpamInfo *)clientSpamInfo
                            fpDevice:(FPDevice *)fpDevice {
    return [[self alloc] initWithManualAuth:manualAuthRequet clientSpamInfo:clientSpamInfo fpDevice:fpDevice];
}

- (instancetype)initWithManualAuth:(ManualAuthRequest *)manualAuthRequet
                    clientSpamInfo:(ClientSpamInfo *)clientSpamInfo
                          fpDevice:(FPDevice *)fpDevice {
    self  = [super init];
    if (self) {
        ManualAuthAesReqData *aesReqData = manualAuthRequet.aesReqData;
        _imei = aesReqData.imei;
        _softType = aesReqData.softType;
        _clientSeq = aesReqData.clientSeqId;
        _clientSeqIdsign = @"18c867f0717aa67b2ab7347505ba07ed";
        _deviceName = aesReqData.deviceName;
        _deviceType = aesReqData.deviceType;
        _language = aesReqData.language;
        _timeZone = aesReqData.timeZone;
        _deviceBrand = aesReqData.deviceBrand;
        _chanel = aesReqData.channel;
        _realCountry = aesReqData.realCountry;
        _bundleID = aesReqData.bundleId;
        _iphoneVer = aesReqData.iphoneVer;
        _osType = [aesReqData.ostype dataUsingEncoding:NSUTF8StringEncoding];
        _adSource = aesReqData.adSource;
        _deviceModel = aesReqData.deviceModel;
        _deviceID = aesReqData.baseRequest.deviceId;
        
        _fpDevice = fpDevice;
        _clientSpamInfo = clientSpamInfo;
    }
    
    return self;
}

+ (instancetype)deviceFromJson:(NSDictionary *)jsonDict {
    return [[self alloc] initWithJson:jsonDict];
}

- (instancetype)initWithJson:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        
        NSString *guid = jsonDict[@"guid"];
        NSString *ts = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        NSString *clientSeqId = [NSString stringWithFormat:@"%@_%@", guid, ts];

        _imei = jsonDict[@"imei"];
        _softType = jsonDict[@"autosoftinfo"];
        _clientSeq = clientSeqId;
        _clientSeqIdsign = @"18c867f0717aa67b2ab7347505ba07ed";
        _deviceName = jsonDict[@"model_name"];
        _deviceType = jsonDict[@"device_info"];
        _language = @"zh_CN";
        _timeZone = @"8.00";
        _deviceBrand = jsonDict[@"brand"];
        _chanel = 0;
        _realCountry = @"cn";
        _bundleID = @"";
        _iphoneVer = @"";
        _osType = [jsonDict[@"android_version"] dataUsingEncoding:NSUTF8StringEncoding];
        _adSource = @"";
        _deviceModel = [NSString stringWithFormat:@"%@%@", _deviceName, jsonDict[@"cpu_abi"]];
        _deviceID = [[NSString stringWithFormat:@"%@\0", [guid substringWithRange:NSMakeRange(0, 15)]] dataUsingEncoding:NSUTF8StringEncoding];
        
        
        // DB data
        
        _autoAuthkeyHex = jsonDict[@"auto_key"];
        NSData *autoAuthKeyData = [NSData dataWithHexString:_autoAuthkeyHex];
        [DBManager saveAutoAuthKey:autoAuthKeyData];
        
        _cookieHex = jsonDict[@"cookie"];
        [DBManager saveCookie:[NSData dataWithHexString:_cookieHex]];
        
        _syncKeyHex = jsonDict[@"sync_key"];
        [DBManager saveSyncKey:[NSData dataWithHexString:_syncKeyHex]];
       
        _uin = [jsonDict[@"uin"] intValue];
        _username = jsonDict[@"user"];
        [DBManager saveAccountInfo:_uin userName:_username nickName:@"" alias:@""];
        
        FPDevice *device = [self paraseFPDevice:jsonDict[@"fp"]];
        ClientSpamInfo *spamInfo = [self parseClientSpamInfo:jsonDict[@"st"]];
        
        _fpDevice = device;
        _clientSpamInfo = spamInfo;
        
    }

    return self;
}

- (FPDevice *)paraseFPDevice:(NSDictionary *)jsonDict {
    FPDevice *fpDevice = [FPDevice new];
    
    FPKeyVals *keyval = [FPKeyVals new];
    keyval.keyValArray = [@
                          [[self key:@"IMEI" withVal:jsonDict[@"IMEI"]],
                           [self key:@"AndroidID" withVal:jsonDict[@"AndroidID"]],
                           [self key:@"PhoneSerial" withVal:jsonDict[@"PhoneSerial"]],
                           [self key:@"cid" withVal:jsonDict[@"cid"]],
                           [self key:@"WidevineDeviceID" withVal:jsonDict[@"WidevineDeviceID"]],
                           [self key:@"WidevineProvisionID" withVal:jsonDict[@"WidevineProvisionID"]],
                           [self key:@"GSFID" withVal:jsonDict[@"GSFID"]],
                           [self key:@"SoterID" withVal:jsonDict[@"SoterID"]],
                           [self key:@"SoterUid" withVal:jsonDict[@"SoterUid"]],
                           [self key:@"FSID" withVal:jsonDict[@"FSID"]],
                           [self key:@"BootID" withVal:jsonDict[@"BootID"]],
                           [self key:@"IMSI" withVal:jsonDict[@"IMSI"]],
                           [self key:@"PhoneNum" withVal:jsonDict[@"PhoneNum"]],
                           [self key:@"WeChatInstallTime" withVal:jsonDict[@"WeChatInstallTime"]],
                           [self key:@"PhoneModel" withVal:jsonDict[@"PhoneModel"]],
                           [self key:@"BuildBoard" withVal:jsonDict[@"BuildBoard"]],
                           [self key:@"BuildBootloader" withVal:jsonDict[@"BuildBootloader"]],
                           [self key:@"SystemBuildDateUTC" withVal:jsonDict[@"SystemBuildDateUTC"]],
                           [self key:@"BuildFP" withVal:jsonDict[@"BuildFP"]],
                           [self key:@"BuildID" withVal:jsonDict[@"BuildID"]],
                           [self key:@"BuildBrand" withVal:jsonDict[@"BuildBrand"]],
                           [self key:@"BuildDevice" withVal:jsonDict[@"BuildDevice"]],
                           [self key:@"BuildProduct" withVal:jsonDict[@"BuildProduct"]],
                           [self key:@"RadioVersion" withVal:jsonDict[@"RadioVersion"]],
                           [self key:@"AndroidVersion" withVal:jsonDict[@"AndroidVersion"]],
                           [self key:@"SdkIntVersion" withVal:jsonDict[@"SdkIntVersion"]],
                           [self key:@"ScreenWidth" withVal:jsonDict[@"ScreenWidth"]],
                           [self key:@"ScreenHeight" withVal:jsonDict[@"ScreenHeight"]],
                           [self key:@"SensorList" withVal:jsonDict[@"SensorList"]],
                           ] mutableCopy];
    
    fpDevice.keyvals = keyval;
    return fpDevice;
}

- (FPKeyVal *)key:(NSString *)key withVal:(NSString *)val {
    FPKeyVal *keyVal = [FPKeyVal new];
    keyVal.key = key;
    keyVal.value = val;
    
    return keyVal;
}

- (ClientSpamInfo *)parseClientSpamInfo:(NSString *)stJson {
    ClientSpamInfo *spamInfo = [ClientSpamInfo new];
    NSDictionary *spamInfoDict = [NSJSONSerialization JSONObjectWithData:[stJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    spamInfo.ccdts = [spamInfoDict[@"ccdts"] intValue];
    spamInfo.ccdts = [spamInfoDict[@"ccdts"] intValue];
    
    NSDictionary *stDict = spamInfoDict[@"st"];
    ST *st = [ST new];
    st.pkgHash3 = stDict[@"PkgHash3"];
    st.ratioFwVer = stDict[@"RatioFwVer"];
    st.osRelVer = stDict[@"OsRelVer"];
    st.imei = stDict[@"IMEI"];
    st.androidId = stDict[@"AndroidID"];
    st.phoneSerial = stDict[@"PhoneSerial"];
    st.phoneModel = stDict[@"PhoneModel"];
    st.cpuCoreCount = [stDict[@"CpuCoreCount"] intValue];
    st.cpuHw = stDict[@"CpuHW"];
    st.selfMac = stDict[@"SelfMAC"];
    st.ssid = stDict[@"SSID"];
    st.bssid = stDict[@"BSSID"];
    st.spInfo = stDict[@"SpInfo"];
    st.apninfo = stDict[@"APNInfo"];
    st.buildFp = stDict[@"BuildFP"];
    st.buildBoard = stDict[@"BuildBoard"];
    st.buildBootloader = stDict[@"BuildBootloader"];
    st.buildBrand = stDict[@"BuildBrand"];
    st.buildDevice = stDict[@"BuildDevice"];
    st.buildHw = stDict[@"BuildHW"];
    st.buildProduct = stDict[@"BuildProduct"];
    st.manufacturer = stDict[@"Manufacturer"];
    st.phoneNum = stDict[@"PhoneNum"];
    st.netType = stDict[@"NetType"];
    st.pkgName = stDict[@"PkgName"];
    st.appName = stDict[@"AppName"];
    st.dataRoot = stDict[@"DataRoot"];
    st.entranceClassLoaderName = stDict[@"EntranceClassLoaderName"];
    st.envBits = [stDict[@"EnvBits"] intValue];
    st.apkleadingMd5 = stDict[@"APKLeadingMD5"];
    st.clientVersion = stDict[@"ClientVersion"];
    st.wxtag = stDict[@"WXTag"];
    st.clientIp = stDict[@"ClientIP"];
    st.language = stDict[@"Language"];
    st.isInCalling = [stDict[@"IsInCalling"] intValue];
    st.isSetScreenLock = [stDict[@"IsSetScreenLock"] intValue];
    st.appInstrumentationClassName = stDict[@"AppInstrumentationClassName"];
    st.amsbinderClassName = stDict[@"AMSBinderClassName"];
    st.amssingletonClassName = stDict[@"AMSSingletonClassName"];
    st.pcodes = stDict[@"PCodes"];
    st.hasQcodes = stDict[@"HasQCodes"];
    st.rcodes0 = stDict[@"RCodes0"];
    st.kernelReleaseNumber = stDict[@"KernelReleaseNumber"];
    st.usbState = [stDict[@"UsbState"] intValue];
    st.apkSignatureMd5 = stDict[@"ApkSignatureMd5"];
    st.googleServiceState = [stDict[@"GoogleServiceState"] intValue];
    st.timeval1 = [stDict[@"Timeval1"] intValue];
    st.spamInfoVersionSeq = [stDict[@"SpamInfoVersionSeq"] intValue];
    st.tbVersionCrc = [stDict[@"InitialSeq"] intValue];
    st.systemFrameworkMd5 = stDict[@"PathMd51"];
    st.systemFrameworkArmMd5 = stDict[@"PathMd52"];
    st.systemFrameworkArm64Md5 = stDict[@"PathMd53"];
    st.systemBinMd5 = stDict[@"PathMd54"];
    st.widevineDeviceId = stDict[@"WidevineDeviceID"];
    st.storageId = stDict[@"StorageID"];
    st.timeVal2 = [stDict[@"Timeval2"] intValue];
    st.weChatInstallTime = [stDict[@"Timestamp"] intValue];
    
    spamInfo.st = st;
    
    return spamInfo;
}


- (NSDictionary *)toDictionary {
    return @{
        @"imei" : _imei,
        @"autosoftinfo" : _softType,
        @"model_name" : _deviceName,
        @"device_info" : _deviceType,
        @"brand" : _deviceBrand,
        @"android_version" : [[NSString alloc] initWithData:_osType encoding:NSUTF8StringEncoding],
        @"cpu_abi" : [_deviceModel stringByReplacingOccurrencesOfString:_deviceName withString:@""],
        @"guid" : [[[NSString alloc] initWithData:_deviceID encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(0, 15)]
    };
}

@end
