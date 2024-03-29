// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: base.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers.h>
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

@class SKBuiltinString_t;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BaseRoot

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
@interface BaseRoot : GPBRootObject
@end

#pragma mark - SKBuiltinBuffer_t

typedef GPB_ENUM(SKBuiltinBuffer_t_FieldNumber) {
  SKBuiltinBuffer_t_FieldNumber_ILen = 1,
  SKBuiltinBuffer_t_FieldNumber_Buffer = 2,
};

@interface SKBuiltinBuffer_t : GPBMessage

@property(nonatomic, readwrite) uint32_t iLen;

@property(nonatomic, readwrite) BOOL hasILen;
@property(nonatomic, readwrite, copy, null_resettable) NSData *buffer;
/** Test to see if @c buffer has been set. */
@property(nonatomic, readwrite) BOOL hasBuffer;

@end

#pragma mark - SKBuiltinChar_t

typedef GPB_ENUM(SKBuiltinChar_t_FieldNumber) {
  SKBuiltinChar_t_FieldNumber_IVal = 1,
};

@interface SKBuiltinChar_t : GPBMessage

@property(nonatomic, readwrite) int32_t iVal;

@property(nonatomic, readwrite) BOOL hasIVal;
@end

#pragma mark - SKBuiltinDouble64_t

typedef GPB_ENUM(SKBuiltinDouble64_t_FieldNumber) {
  SKBuiltinDouble64_t_FieldNumber_DVal = 1,
};

@interface SKBuiltinDouble64_t : GPBMessage

@property(nonatomic, readwrite) double dVal;

@property(nonatomic, readwrite) BOOL hasDVal;
@end

#pragma mark - SKBuiltinFloat32_t

typedef GPB_ENUM(SKBuiltinFloat32_t_FieldNumber) {
  SKBuiltinFloat32_t_FieldNumber_FVal = 1,
};

@interface SKBuiltinFloat32_t : GPBMessage

@property(nonatomic, readwrite) float fVal;

@property(nonatomic, readwrite) BOOL hasFVal;
@end

#pragma mark - SKBuiltinInt16_t

typedef GPB_ENUM(SKBuiltinInt16_t_FieldNumber) {
  SKBuiltinInt16_t_FieldNumber_IVal = 1,
};

@interface SKBuiltinInt16_t : GPBMessage

@property(nonatomic, readwrite) int32_t iVal;

@property(nonatomic, readwrite) BOOL hasIVal;
@end

#pragma mark - SKBuiltinInt32_t

typedef GPB_ENUM(SKBuiltinInt32_t_FieldNumber) {
  SKBuiltinInt32_t_FieldNumber_IVal = 1,
};

@interface SKBuiltinInt32_t : GPBMessage

@property(nonatomic, readwrite) uint32_t iVal;

@property(nonatomic, readwrite) BOOL hasIVal;
@end

#pragma mark - SKBuiltinInt64_t

typedef GPB_ENUM(SKBuiltinInt64_t_FieldNumber) {
  SKBuiltinInt64_t_FieldNumber_LlVal = 1,
};

@interface SKBuiltinInt64_t : GPBMessage

@property(nonatomic, readwrite) int64_t llVal;

@property(nonatomic, readwrite) BOOL hasLlVal;
@end

#pragma mark - SKBuiltinInt8_t

typedef GPB_ENUM(SKBuiltinInt8_t_FieldNumber) {
  SKBuiltinInt8_t_FieldNumber_IVal = 1,
};

@interface SKBuiltinInt8_t : GPBMessage

@property(nonatomic, readwrite) int32_t iVal;

@property(nonatomic, readwrite) BOOL hasIVal;
@end

#pragma mark - SKBuiltinString_t

typedef GPB_ENUM(SKBuiltinString_t_FieldNumber) {
  SKBuiltinString_t_FieldNumber_String = 1,
};

@interface SKBuiltinString_t : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *string;
/** Test to see if @c string has been set. */
@property(nonatomic, readwrite) BOOL hasString;

@end

#pragma mark - SKBuiltinUchar_t

typedef GPB_ENUM(SKBuiltinUchar_t_FieldNumber) {
  SKBuiltinUchar_t_FieldNumber_UiVal = 1,
};

@interface SKBuiltinUchar_t : GPBMessage

@property(nonatomic, readwrite) uint32_t uiVal;

@property(nonatomic, readwrite) BOOL hasUiVal;
@end

#pragma mark - SKBuiltinUint16_t

typedef GPB_ENUM(SKBuiltinUint16_t_FieldNumber) {
  SKBuiltinUint16_t_FieldNumber_UiVal = 1,
};

@interface SKBuiltinUint16_t : GPBMessage

@property(nonatomic, readwrite) uint32_t uiVal;

@property(nonatomic, readwrite) BOOL hasUiVal;
@end

#pragma mark - SKBuiltinUint32_t

typedef GPB_ENUM(SKBuiltinUint32_t_FieldNumber) {
  SKBuiltinUint32_t_FieldNumber_UiVal = 1,
};

@interface SKBuiltinUint32_t : GPBMessage

@property(nonatomic, readwrite) uint32_t uiVal;

@property(nonatomic, readwrite) BOOL hasUiVal;
@end

#pragma mark - SKBuiltinUint64_t

typedef GPB_ENUM(SKBuiltinUint64_t_FieldNumber) {
  SKBuiltinUint64_t_FieldNumber_UllVal = 1,
};

@interface SKBuiltinUint64_t : GPBMessage

@property(nonatomic, readwrite) uint64_t ullVal;

@property(nonatomic, readwrite) BOOL hasUllVal;
@end

#pragma mark - SKBuiltinUint8_t

typedef GPB_ENUM(SKBuiltinUint8_t_FieldNumber) {
  SKBuiltinUint8_t_FieldNumber_UiVal = 1,
};

@interface SKBuiltinUint8_t : GPBMessage

@property(nonatomic, readwrite) uint32_t uiVal;

@property(nonatomic, readwrite) BOOL hasUiVal;
@end

#pragma mark - BaseRequest

typedef GPB_ENUM(BaseRequest_FieldNumber) {
  BaseRequest_FieldNumber_SessionKey = 1,
  BaseRequest_FieldNumber_Uin = 2,
  BaseRequest_FieldNumber_DeviceId = 3,
  BaseRequest_FieldNumber_ClientVersion = 4,
  BaseRequest_FieldNumber_DeviceType = 5,
  BaseRequest_FieldNumber_Scene = 6,
};

@interface BaseRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *sessionKey;
/** Test to see if @c sessionKey has been set. */
@property(nonatomic, readwrite) BOOL hasSessionKey;

@property(nonatomic, readwrite) uint32_t uin;

@property(nonatomic, readwrite) BOOL hasUin;
@property(nonatomic, readwrite, copy, null_resettable) NSData *deviceId;
/** Test to see if @c deviceId has been set. */
@property(nonatomic, readwrite) BOOL hasDeviceId;

@property(nonatomic, readwrite) int32_t clientVersion;

@property(nonatomic, readwrite) BOOL hasClientVersion;
@property(nonatomic, readwrite, copy, null_resettable) NSData *deviceType;
/** Test to see if @c deviceType has been set. */
@property(nonatomic, readwrite) BOOL hasDeviceType;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - BaseResponse

typedef GPB_ENUM(BaseResponse_FieldNumber) {
  BaseResponse_FieldNumber_Ret = 1,
  BaseResponse_FieldNumber_ErrMsg = 2,
};

@interface BaseResponse : GPBMessage

@property(nonatomic, readwrite) int32_t ret;

@property(nonatomic, readwrite) BOOL hasRet;
@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *errMsg;
/** Test to see if @c errMsg has been set. */
@property(nonatomic, readwrite) BOOL hasErrMsg;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
