// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: mmextdevice.proto

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

@class BaseResponse;
@class CmdList;
@class ExtDeviceLoginConfirmErrorRet;
@class ExtDeviceLoginConfirmExpiredRet;
@class ExtDeviceLoginConfirmOKRet;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum ExtDevLoginType

typedef GPB_ENUM(ExtDevLoginType) {
  ExtDevLoginType_ExtdevLogintypeNormal = 0,
  ExtDevLoginType_ExtdevLogintypeTmp = 1,
  ExtDevLoginType_ExtdevLogintypePair = 2,
};

GPBEnumDescriptor *ExtDevLoginType_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL ExtDevLoginType_IsValidValue(int32_t value);

#pragma mark - MmextdeviceRoot

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
@interface MmextdeviceRoot : GPBRootObject
@end

#pragma mark - ExtDeviceLoginConfirmGetRequest

typedef GPB_ENUM(ExtDeviceLoginConfirmGetRequest_FieldNumber) {
  ExtDeviceLoginConfirmGetRequest_FieldNumber_LoginURL = 1,
};

@interface ExtDeviceLoginConfirmGetRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *loginURL;
/** Test to see if @c loginURL has been set. */
@property(nonatomic, readwrite) BOOL hasLoginURL;

@end

#pragma mark - ExtDeviceLoginConfirmOKRet

typedef GPB_ENUM(ExtDeviceLoginConfirmOKRet_FieldNumber) {
  ExtDeviceLoginConfirmOKRet_FieldNumber_IconType = 1,
  ExtDeviceLoginConfirmOKRet_FieldNumber_ContentStr = 2,
  ExtDeviceLoginConfirmOKRet_FieldNumber_ButtonOkStr = 3,
  ExtDeviceLoginConfirmOKRet_FieldNumber_ButtonCancelStr = 4,
  ExtDeviceLoginConfirmOKRet_FieldNumber_ReqSessionLimit = 5,
  ExtDeviceLoginConfirmOKRet_FieldNumber_ConfirmTimeOut = 6,
  ExtDeviceLoginConfirmOKRet_FieldNumber_LoginedDevTip = 7,
  ExtDeviceLoginConfirmOKRet_FieldNumber_TitleStr = 8,
};

@interface ExtDeviceLoginConfirmOKRet : GPBMessage

@property(nonatomic, readwrite) uint32_t iconType;

@property(nonatomic, readwrite) BOOL hasIconType;
@property(nonatomic, readwrite, copy, null_resettable) NSString *contentStr;
/** Test to see if @c contentStr has been set. */
@property(nonatomic, readwrite) BOOL hasContentStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *buttonOkStr;
/** Test to see if @c buttonOkStr has been set. */
@property(nonatomic, readwrite) BOOL hasButtonOkStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *buttonCancelStr;
/** Test to see if @c buttonCancelStr has been set. */
@property(nonatomic, readwrite) BOOL hasButtonCancelStr;

@property(nonatomic, readwrite) uint32_t reqSessionLimit;

@property(nonatomic, readwrite) BOOL hasReqSessionLimit;
@property(nonatomic, readwrite) uint32_t confirmTimeOut;

@property(nonatomic, readwrite) BOOL hasConfirmTimeOut;
@property(nonatomic, readwrite, copy, null_resettable) NSString *loginedDevTip;
/** Test to see if @c loginedDevTip has been set. */
@property(nonatomic, readwrite) BOOL hasLoginedDevTip;

@property(nonatomic, readwrite, copy, null_resettable) NSString *titleStr;
/** Test to see if @c titleStr has been set. */
@property(nonatomic, readwrite) BOOL hasTitleStr;

@end

#pragma mark - ExtDeviceLoginConfirmErrorRet

typedef GPB_ENUM(ExtDeviceLoginConfirmErrorRet_FieldNumber) {
  ExtDeviceLoginConfirmErrorRet_FieldNumber_IconType = 1,
  ExtDeviceLoginConfirmErrorRet_FieldNumber_ContentStr = 2,
  ExtDeviceLoginConfirmErrorRet_FieldNumber_TitleStr = 3,
  ExtDeviceLoginConfirmErrorRet_FieldNumber_ButtonStr = 4,
};

@interface ExtDeviceLoginConfirmErrorRet : GPBMessage

@property(nonatomic, readwrite) uint32_t iconType;

@property(nonatomic, readwrite) BOOL hasIconType;
@property(nonatomic, readwrite, copy, null_resettable) NSString *contentStr;
/** Test to see if @c contentStr has been set. */
@property(nonatomic, readwrite) BOOL hasContentStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *titleStr;
/** Test to see if @c titleStr has been set. */
@property(nonatomic, readwrite) BOOL hasTitleStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *buttonStr;
/** Test to see if @c buttonStr has been set. */
@property(nonatomic, readwrite) BOOL hasButtonStr;

@end

#pragma mark - ExtDeviceLoginConfirmExpiredRet

typedef GPB_ENUM(ExtDeviceLoginConfirmExpiredRet_FieldNumber) {
  ExtDeviceLoginConfirmExpiredRet_FieldNumber_IconType = 1,
  ExtDeviceLoginConfirmExpiredRet_FieldNumber_ContentStr = 2,
  ExtDeviceLoginConfirmExpiredRet_FieldNumber_ButtonStr = 3,
  ExtDeviceLoginConfirmExpiredRet_FieldNumber_TitleStr = 4,
};

@interface ExtDeviceLoginConfirmExpiredRet : GPBMessage

@property(nonatomic, readwrite) uint32_t iconType;

@property(nonatomic, readwrite) BOOL hasIconType;
@property(nonatomic, readwrite, copy, null_resettable) NSString *contentStr;
/** Test to see if @c contentStr has been set. */
@property(nonatomic, readwrite) BOOL hasContentStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *buttonStr;
/** Test to see if @c buttonStr has been set. */
@property(nonatomic, readwrite) BOOL hasButtonStr;

@property(nonatomic, readwrite, copy, null_resettable) NSString *titleStr;
/** Test to see if @c titleStr has been set. */
@property(nonatomic, readwrite) BOOL hasTitleStr;

@end

#pragma mark - ExtDeviceLoginConfirmGetResponse

typedef GPB_ENUM(ExtDeviceLoginConfirmGetResponse_FieldNumber) {
  ExtDeviceLoginConfirmGetResponse_FieldNumber_BaseResponse = 1,
  ExtDeviceLoginConfirmGetResponse_FieldNumber_Okret = 2,
  ExtDeviceLoginConfirmGetResponse_FieldNumber_ErrorRet = 3,
  ExtDeviceLoginConfirmGetResponse_FieldNumber_ExpiredRet = 4,
  ExtDeviceLoginConfirmGetResponse_FieldNumber_DeviceNameStr = 5,
};

@interface ExtDeviceLoginConfirmGetResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite, strong, null_resettable) ExtDeviceLoginConfirmOKRet *okret;
/** Test to see if @c okret has been set. */
@property(nonatomic, readwrite) BOOL hasOkret;

@property(nonatomic, readwrite, strong, null_resettable) ExtDeviceLoginConfirmErrorRet *errorRet;
/** Test to see if @c errorRet has been set. */
@property(nonatomic, readwrite) BOOL hasErrorRet;

@property(nonatomic, readwrite, strong, null_resettable) ExtDeviceLoginConfirmExpiredRet *expiredRet;
/** Test to see if @c expiredRet has been set. */
@property(nonatomic, readwrite) BOOL hasExpiredRet;

@property(nonatomic, readwrite, copy, null_resettable) NSString *deviceNameStr;
/** Test to see if @c deviceNameStr has been set. */
@property(nonatomic, readwrite) BOOL hasDeviceNameStr;

@end

#pragma mark - ExtDeviceLoginConfirmOKRequest

typedef GPB_ENUM(ExtDeviceLoginConfirmOKRequest_FieldNumber) {
  ExtDeviceLoginConfirmOKRequest_FieldNumber_LoginURL = 1,
  ExtDeviceLoginConfirmOKRequest_FieldNumber_SessionList = 2,
  ExtDeviceLoginConfirmOKRequest_FieldNumber_UnReadChatContactListArray = 3,
};

@interface ExtDeviceLoginConfirmOKRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *loginURL;
/** Test to see if @c loginURL has been set. */
@property(nonatomic, readwrite) BOOL hasLoginURL;

@property(nonatomic, readwrite, copy, null_resettable) NSString *sessionList;
/** Test to see if @c sessionList has been set. */
@property(nonatomic, readwrite) BOOL hasSessionList;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *unReadChatContactListArray;
/** The number of items in @c unReadChatContactListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger unReadChatContactListArray_Count;

@end

#pragma mark - ExtDeviceLoginConfirmOKResponse

typedef GPB_ENUM(ExtDeviceLoginConfirmOKResponse_FieldNumber) {
  ExtDeviceLoginConfirmOKResponse_FieldNumber_BaseResponse = 1,
};

@interface ExtDeviceLoginConfirmOKResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - ExtDeviceLoginConfirmCancelRequest

typedef GPB_ENUM(ExtDeviceLoginConfirmCancelRequest_FieldNumber) {
  ExtDeviceLoginConfirmCancelRequest_FieldNumber_LoginURL = 1,
};

@interface ExtDeviceLoginConfirmCancelRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *loginURL;
/** Test to see if @c loginURL has been set. */
@property(nonatomic, readwrite) BOOL hasLoginURL;

@end

#pragma mark - ExtDeviceLoginConfirmCancelResponse

typedef GPB_ENUM(ExtDeviceLoginConfirmCancelResponse_FieldNumber) {
  ExtDeviceLoginConfirmCancelResponse_FieldNumber_BaseResponse = 1,
};

@interface ExtDeviceLoginConfirmCancelResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - ExtDeviceInitRequest

typedef GPB_ENUM(ExtDeviceInitRequest_FieldNumber) {
  ExtDeviceInitRequest_FieldNumber_UserName = 1,
};

@interface ExtDeviceInitRequest : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *userName;
/** Test to see if @c userName has been set. */
@property(nonatomic, readwrite) BOOL hasUserName;

@end

#pragma mark - ExtDeviceInitResponse

typedef GPB_ENUM(ExtDeviceInitResponse_FieldNumber) {
  ExtDeviceInitResponse_FieldNumber_BaseResponse = 1,
  ExtDeviceInitResponse_FieldNumber_CmdList = 2,
  ExtDeviceInitResponse_FieldNumber_ChatContactListArray = 3,
};

@interface ExtDeviceInitResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite, strong, null_resettable) CmdList *cmdList;
/** Test to see if @c cmdList has been set. */
@property(nonatomic, readwrite) BOOL hasCmdList;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *chatContactListArray;
/** The number of items in @c chatContactListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger chatContactListArray_Count;

@end

#pragma mark - ExtDeviceControlRequest

typedef GPB_ENUM(ExtDeviceControlRequest_FieldNumber) {
  ExtDeviceControlRequest_FieldNumber_OpType = 1,
  ExtDeviceControlRequest_FieldNumber_LockDevice = 2,
};

@interface ExtDeviceControlRequest : GPBMessage

@property(nonatomic, readwrite) uint32_t opType;

@property(nonatomic, readwrite) BOOL hasOpType;
@property(nonatomic, readwrite) uint32_t lockDevice;

@property(nonatomic, readwrite) BOOL hasLockDevice;
@end

#pragma mark - ExtDeviceControlResponse

typedef GPB_ENUM(ExtDeviceControlResponse_FieldNumber) {
  ExtDeviceControlResponse_FieldNumber_BaseResponse = 1,
};

@interface ExtDeviceControlResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)