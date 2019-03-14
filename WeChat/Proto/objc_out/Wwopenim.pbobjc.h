// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: wwopenim.proto

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

@class AcctTypeResource;
@class AppIdResource;
@class BaseResponse;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - WwopenimRoot

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
@interface WwopenimRoot : GPBRootObject
@end

#pragma mark - GetOpenIMResourceReq

typedef GPB_ENUM(GetOpenIMResourceReq_FieldNumber) {
  GetOpenIMResourceReq_FieldNumber_Language = 1,
  GetOpenIMResourceReq_FieldNumber_AppId = 2,
  GetOpenIMResourceReq_FieldNumber_WordingIdArray = 3,
};

@interface GetOpenIMResourceReq : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *language;
/** Test to see if @c language has been set. */
@property(nonatomic, readwrite) BOOL hasLanguage;

@property(nonatomic, readwrite, copy, null_resettable) NSString *appId;
/** Test to see if @c appId has been set. */
@property(nonatomic, readwrite) BOOL hasAppId;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *wordingIdArray;
/** The number of items in @c wordingIdArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger wordingIdArray_Count;

@end

#pragma mark - AppIdResource

typedef GPB_ENUM(AppIdResource_FieldNumber) {
  AppIdResource_FieldNumber_FunctionFlag = 1,
};

@interface AppIdResource : GPBMessage

/**
 *    repeated urls =
 *    repeated wordings =
 **/
@property(nonatomic, readwrite) uint32_t functionFlag;

@property(nonatomic, readwrite) BOOL hasFunctionFlag;
@end

#pragma mark - AcctTypeResource

typedef GPB_ENUM(AcctTypeResource_FieldNumber) {
  AcctTypeResource_FieldNumber_AcctTypeId = 1,
};

/**
 * {"urls":[],"wordings":[],"acctTypeId":"acctTypeId"}
 **/
@interface AcctTypeResource : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *acctTypeId;
/** Test to see if @c acctTypeId has been set. */
@property(nonatomic, readwrite) BOOL hasAcctTypeId;

@end

#pragma mark - GetOpenIMResourceResp

typedef GPB_ENUM(GetOpenIMResourceResp_FieldNumber) {
  GetOpenIMResourceResp_FieldNumber_BaseResponse = 1,
  GetOpenIMResourceResp_FieldNumber_AppidResource = 2,
  GetOpenIMResourceResp_FieldNumber_AcctTypeResource = 3,
};

@interface GetOpenIMResourceResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite, strong, null_resettable) AppIdResource *appidResource;
/** Test to see if @c appidResource has been set. */
@property(nonatomic, readwrite) BOOL hasAppidResource;

@property(nonatomic, readwrite, strong, null_resettable) AcctTypeResource *acctTypeResource;
/** Test to see if @c acctTypeResource has been set. */
@property(nonatomic, readwrite) BOOL hasAcctTypeResource;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
