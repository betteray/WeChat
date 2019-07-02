// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: mmreport.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class CliReportKVDataPackage;
@class HeavyUserReqInfo;
@class HeavyUserRespInfo;
@class KVCommReportItem;
@class NewStrategyItem;
@class StrategyInterval;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MmreportRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface MmreportRoot : GPBRootObject
@end

#pragma mark - HeavyUserReqInfo

typedef GPB_ENUM(HeavyUserReqInfo_FieldNumber) {
  HeavyUserReqInfo_FieldNumber_MonitorIdMapVersion = 1,
};

@interface HeavyUserReqInfo : GPBMessage

@property(nonatomic, readwrite) uint32_t monitorIdMapVersion;

@property(nonatomic, readwrite) BOOL hasMonitorIdMapVersion;
@end

#pragma mark - KVCommReportItem

typedef GPB_ENUM(KVCommReportItem_FieldNumber) {
  KVCommReportItem_FieldNumber_LogId = 1,
  KVCommReportItem_FieldNumber_Value = 2,
  KVCommReportItem_FieldNumber_StartTime = 3,
  KVCommReportItem_FieldNumber_EndTime = 4,
  KVCommReportItem_FieldNumber_Count = 5,
  KVCommReportItem_FieldNumber_RefreshTime = 6,
  KVCommReportItem_FieldNumber_Type = 7,
};

@interface KVCommReportItem : GPBMessage

@property(nonatomic, readwrite) uint32_t logId;

@property(nonatomic, readwrite) BOOL hasLogId;
@property(nonatomic, readwrite, copy, null_resettable) NSData *value;
/** Test to see if @c value has been set. */
@property(nonatomic, readwrite) BOOL hasValue;

@property(nonatomic, readwrite) uint32_t startTime;

@property(nonatomic, readwrite) BOOL hasStartTime;
@property(nonatomic, readwrite) uint32_t endTime;

@property(nonatomic, readwrite) BOOL hasEndTime;
@property(nonatomic, readwrite) uint32_t count;

@property(nonatomic, readwrite) BOOL hasCount;
@property(nonatomic, readwrite) uint32_t refreshTime;

@property(nonatomic, readwrite) BOOL hasRefreshTime;
@property(nonatomic, readwrite) uint32_t type;

@property(nonatomic, readwrite) BOOL hasType;
@end

#pragma mark - CliReportKVDataPackage

typedef GPB_ENUM(CliReportKVDataPackage_FieldNumber) {
  CliReportKVDataPackage_FieldNumber_Uin = 1,
  CliReportKVDataPackage_FieldNumber_ClientVersion = 2,
  CliReportKVDataPackage_FieldNumber_NetType = 3,
  CliReportKVDataPackage_FieldNumber_ItemListArray = 4,
  CliReportKVDataPackage_FieldNumber_DeviceModel = 5,
  CliReportKVDataPackage_FieldNumber_DeviceBrand = 6,
  CliReportKVDataPackage_FieldNumber_OsName = 7,
  CliReportKVDataPackage_FieldNumber_OsVersion = 8,
  CliReportKVDataPackage_FieldNumber_LanguageVer = 9,
  CliReportKVDataPackage_FieldNumber_Datatype = 10,
};

@interface CliReportKVDataPackage : GPBMessage

@property(nonatomic, readwrite) uint32_t uin;

@property(nonatomic, readwrite) BOOL hasUin;
@property(nonatomic, readwrite) uint32_t clientVersion;

@property(nonatomic, readwrite) BOOL hasClientVersion;
@property(nonatomic, readwrite) uint32_t netType;

@property(nonatomic, readwrite) BOOL hasNetType;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<KVCommReportItem*> *itemListArray;
/** The number of items in @c itemListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger itemListArray_Count;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceModel;
/** Test to see if @c deviceModel has been set. */
@property(nonatomic, readwrite) BOOL hasDeviceModel;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceBrand;
/** Test to see if @c deviceBrand has been set. */
@property(nonatomic, readwrite) BOOL hasDeviceBrand;

@property(nonatomic, readwrite, copy, null_resettable) NSString *osName;
/** Test to see if @c osName has been set. */
@property(nonatomic, readwrite) BOOL hasOsName;

@property(nonatomic, readwrite, copy, null_resettable) NSString *osVersion;
/** Test to see if @c osVersion has been set. */
@property(nonatomic, readwrite) BOOL hasOsVersion;

@property(nonatomic, readwrite, copy, null_resettable) NSString *languageVer;
/** Test to see if @c languageVer has been set. */
@property(nonatomic, readwrite) BOOL hasLanguageVer;

@property(nonatomic, readwrite) uint32_t datatype;

@property(nonatomic, readwrite) BOOL hasDatatype;
@end

#pragma mark - CliReportKVReq

typedef GPB_ENUM(CliReportKVReq_FieldNumber) {
  CliReportKVReq_FieldNumber_GeneralVersion = 1,
  CliReportKVReq_FieldNumber_SpecialVersion = 2,
  CliReportKVReq_FieldNumber_WhiteOrBlackUinVersion = 3,
  CliReportKVReq_FieldNumber_DataPkgArray = 4,
  CliReportKVReq_FieldNumber_RandomEncryKey = 5,
  CliReportKVReq_FieldNumber_HeavyUserInfo = 6,
};

/**
 * CliReportKVReq
 **/
@interface CliReportKVReq : GPBMessage

@property(nonatomic, readwrite) uint32_t generalVersion;

@property(nonatomic, readwrite) BOOL hasGeneralVersion;
@property(nonatomic, readwrite) uint32_t specialVersion;

@property(nonatomic, readwrite) BOOL hasSpecialVersion;
@property(nonatomic, readwrite) uint32_t whiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasWhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<CliReportKVDataPackage*> *dataPkgArray;
/** The number of items in @c dataPkgArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger dataPkgArray_Count;

@property(nonatomic, readwrite, copy, null_resettable) NSData *randomEncryKey;
/** Test to see if @c randomEncryKey has been set. */
@property(nonatomic, readwrite) BOOL hasRandomEncryKey;

@property(nonatomic, readwrite, strong, null_resettable) HeavyUserReqInfo *heavyUserInfo;
/** Test to see if @c heavyUserInfo has been set. */
@property(nonatomic, readwrite) BOOL hasHeavyUserInfo;

@end

#pragma mark - HeavyUserRespInfo

typedef GPB_ENUM(HeavyUserRespInfo_FieldNumber) {
  HeavyUserRespInfo_FieldNumber_MonitorIdMapVersion = 1,
  HeavyUserRespInfo_FieldNumber_MonitorIdMapStrategysArray = 2,
  HeavyUserRespInfo_FieldNumber_RespType = 3,
};

@interface HeavyUserRespInfo : GPBMessage

@property(nonatomic, readwrite) uint32_t monitorIdMapVersion;

@property(nonatomic, readwrite) BOOL hasMonitorIdMapVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<StrategyInterval*> *monitorIdMapStrategysArray;
/** The number of items in @c monitorIdMapStrategysArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger monitorIdMapStrategysArray_Count;

@property(nonatomic, readwrite) uint32_t respType;

@property(nonatomic, readwrite) BOOL hasRespType;
@end

#pragma mark - NewStrategyItem

typedef GPB_ENUM(NewStrategyItem_FieldNumber) {
  NewStrategyItem_FieldNumber_LogId = 1,
  NewStrategyItem_FieldNumber_ReportCycle = 2,
  NewStrategyItem_FieldNumber_ReportFlag = 3,
  NewStrategyItem_FieldNumber_SampleRatio = 4,
  NewStrategyItem_FieldNumber_SampleMode = 5,
  NewStrategyItem_FieldNumber_SampleValidInterval = 6,
  NewStrategyItem_FieldNumber_MonitorFlag = 7,
  NewStrategyItem_FieldNumber_Type = 8,
};

@interface NewStrategyItem : GPBMessage

@property(nonatomic, readwrite) uint32_t logId;

@property(nonatomic, readwrite) BOOL hasLogId;
@property(nonatomic, readwrite) uint32_t reportCycle;

@property(nonatomic, readwrite) BOOL hasReportCycle;
@property(nonatomic, readwrite) uint32_t reportFlag;

@property(nonatomic, readwrite) BOOL hasReportFlag;
@property(nonatomic, readwrite) uint32_t sampleRatio;

@property(nonatomic, readwrite) BOOL hasSampleRatio;
@property(nonatomic, readwrite) uint32_t sampleMode;

@property(nonatomic, readwrite) BOOL hasSampleMode;
@property(nonatomic, readwrite) uint32_t sampleValidInterval;

@property(nonatomic, readwrite) BOOL hasSampleValidInterval;
@property(nonatomic, readwrite) uint32_t monitorFlag;

@property(nonatomic, readwrite) BOOL hasMonitorFlag;
@property(nonatomic, readwrite) uint32_t type;

@property(nonatomic, readwrite) BOOL hasType;
@end

#pragma mark - StrategyInterval

typedef GPB_ENUM(StrategyInterval_FieldNumber) {
  StrategyInterval_FieldNumber_LogIdbegin = 1,
  StrategyInterval_FieldNumber_LogIdend = 2,
  StrategyInterval_FieldNumber_StrategyItemArray = 3,
};

@interface StrategyInterval : GPBMessage

@property(nonatomic, readwrite) uint32_t logIdbegin;

@property(nonatomic, readwrite) BOOL hasLogIdbegin;
@property(nonatomic, readwrite) uint32_t logIdend;

@property(nonatomic, readwrite) BOOL hasLogIdend;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NewStrategyItem*> *strategyItemArray;
/** The number of items in @c strategyItemArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger strategyItemArray_Count;

@end

#pragma mark - CliReportKVResp

typedef GPB_ENUM(CliReportKVResp_FieldNumber) {
  CliReportKVResp_FieldNumber_Ret = 1,
  CliReportKVResp_FieldNumber_GeneralVersion = 2,
  CliReportKVResp_FieldNumber_SpecialVersion = 3,
  CliReportKVResp_FieldNumber_WhiteOrBlackUinVersion = 4,
  CliReportKVResp_FieldNumber_GeneralStrategiesArray = 5,
  CliReportKVResp_FieldNumber_MaxValidDataTime = 8,
  CliReportKVResp_FieldNumber_BanReportTime = 9,
  CliReportKVResp_FieldNumber_AskSvrStrategyInterval = 10,
  CliReportKVResp_FieldNumber_HeavyUserInfo = 11,
};

@interface CliReportKVResp : GPBMessage

@property(nonatomic, readwrite) uint32_t ret;

@property(nonatomic, readwrite) BOOL hasRet;
@property(nonatomic, readwrite) uint32_t generalVersion;

@property(nonatomic, readwrite) BOOL hasGeneralVersion;
@property(nonatomic, readwrite) uint32_t specialVersion;

@property(nonatomic, readwrite) BOOL hasSpecialVersion;
@property(nonatomic, readwrite) uint32_t whiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasWhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<StrategyInterval*> *generalStrategiesArray;
/** The number of items in @c generalStrategiesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger generalStrategiesArray_Count;

@property(nonatomic, readwrite) uint32_t maxValidDataTime;

@property(nonatomic, readwrite) BOOL hasMaxValidDataTime;
@property(nonatomic, readwrite) uint32_t banReportTime;

@property(nonatomic, readwrite) BOOL hasBanReportTime;
@property(nonatomic, readwrite) uint32_t askSvrStrategyInterval;

@property(nonatomic, readwrite) BOOL hasAskSvrStrategyInterval;
@property(nonatomic, readwrite, strong, null_resettable) HeavyUserRespInfo *heavyUserInfo;
/** Test to see if @c heavyUserInfo has been set. */
@property(nonatomic, readwrite) BOOL hasHeavyUserInfo;

@end

#pragma mark - GetCliKVStrategyReq

typedef GPB_ENUM(GetCliKVStrategyReq_FieldNumber) {
  GetCliKVStrategyReq_FieldNumber_GeneralVersion = 1,
  GetCliKVStrategyReq_FieldNumber_SpecialVersion = 2,
  GetCliKVStrategyReq_FieldNumber_WhiteOrBlackUinVersion = 3,
  GetCliKVStrategyReq_FieldNumber_RandomEncryKeyArray = 4,
  GetCliKVStrategyReq_FieldNumber_KvgeneralVersion = 5,
  GetCliKVStrategyReq_FieldNumber_KvspecialVersion = 6,
  GetCliKVStrategyReq_FieldNumber_KvwhiteOrBlackUinVersion = 7,
  GetCliKVStrategyReq_FieldNumber_HeavyUserInfo = 8,
};

@interface GetCliKVStrategyReq : GPBMessage

@property(nonatomic, readwrite) uint32_t generalVersion;

@property(nonatomic, readwrite) BOOL hasGeneralVersion;
@property(nonatomic, readwrite) uint32_t specialVersion;

@property(nonatomic, readwrite) BOOL hasSpecialVersion;
@property(nonatomic, readwrite) uint32_t whiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasWhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSData*> *randomEncryKeyArray;
/** The number of items in @c randomEncryKeyArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger randomEncryKeyArray_Count;

@property(nonatomic, readwrite) uint32_t kvgeneralVersion;

@property(nonatomic, readwrite) BOOL hasKvgeneralVersion;
@property(nonatomic, readwrite) uint32_t kvspecialVersion;

@property(nonatomic, readwrite) BOOL hasKvspecialVersion;
@property(nonatomic, readwrite) uint32_t kvwhiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasKvwhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) HeavyUserRespInfo *heavyUserInfo;
/** Test to see if @c heavyUserInfo has been set. */
@property(nonatomic, readwrite) BOOL hasHeavyUserInfo;

@end

#pragma mark - GetCliKVStrategyResp

typedef GPB_ENUM(GetCliKVStrategyResp_FieldNumber) {
  GetCliKVStrategyResp_FieldNumber_Ret = 1,
  GetCliKVStrategyResp_FieldNumber_GeneralVersion = 2,
  GetCliKVStrategyResp_FieldNumber_SpecialVersion = 3,
  GetCliKVStrategyResp_FieldNumber_WhiteOrBlackUinVersion = 4,
  GetCliKVStrategyResp_FieldNumber_KvspecialStrategiesArray = 5,
  GetCliKVStrategyResp_FieldNumber_MaxValidDataTime = 8,
  GetCliKVStrategyResp_FieldNumber_BanReportTime = 9,
  GetCliKVStrategyResp_FieldNumber_AskSvrStrategyInterval = 10,
  GetCliKVStrategyResp_FieldNumber_KvgeneralVersion = 11,
  GetCliKVStrategyResp_FieldNumber_KvspecialVersion = 12,
  GetCliKVStrategyResp_FieldNumber_KvwhiteOrBlackUinVersion = 13,
  GetCliKVStrategyResp_FieldNumber_KvgeneralStrategiesArray = 14,
  GetCliKVStrategyResp_FieldNumber_HeavyUserInfo = 17,
  GetCliKVStrategyResp_FieldNumber_Aaa = 19,
};

@interface GetCliKVStrategyResp : GPBMessage

@property(nonatomic, readwrite) uint32_t ret;

@property(nonatomic, readwrite) BOOL hasRet;
@property(nonatomic, readwrite) uint32_t generalVersion;

@property(nonatomic, readwrite) BOOL hasGeneralVersion;
@property(nonatomic, readwrite) uint32_t specialVersion;

@property(nonatomic, readwrite) BOOL hasSpecialVersion;
@property(nonatomic, readwrite) uint32_t whiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasWhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<StrategyInterval*> *kvspecialStrategiesArray;
/** The number of items in @c kvspecialStrategiesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger kvspecialStrategiesArray_Count;

@property(nonatomic, readwrite) uint32_t maxValidDataTime;

@property(nonatomic, readwrite) BOOL hasMaxValidDataTime;
@property(nonatomic, readwrite) uint32_t banReportTime;

@property(nonatomic, readwrite) BOOL hasBanReportTime;
@property(nonatomic, readwrite) uint32_t askSvrStrategyInterval;

@property(nonatomic, readwrite) BOOL hasAskSvrStrategyInterval;
@property(nonatomic, readwrite) uint32_t kvgeneralVersion;

@property(nonatomic, readwrite) BOOL hasKvgeneralVersion;
@property(nonatomic, readwrite) uint32_t kvspecialVersion;

@property(nonatomic, readwrite) BOOL hasKvspecialVersion;
@property(nonatomic, readwrite) uint32_t kvwhiteOrBlackUinVersion;

@property(nonatomic, readwrite) BOOL hasKvwhiteOrBlackUinVersion;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<StrategyInterval*> *kvgeneralStrategiesArray;
/** The number of items in @c kvgeneralStrategiesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger kvgeneralStrategiesArray_Count;

@property(nonatomic, readwrite, strong, null_resettable) HeavyUserRespInfo *heavyUserInfo;
/** Test to see if @c heavyUserInfo has been set. */
@property(nonatomic, readwrite) BOOL hasHeavyUserInfo;

@property(nonatomic, readwrite) uint32_t aaa;

@property(nonatomic, readwrite) BOOL hasAaa;
@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)