// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: mmremind.proto

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

@class BaseRequest;
@class BaseResponse;
@class CmdList;
@class RemindItem;
@class RemindMember;
@class SKBuiltinBuffer_t;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MmremindRoot

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
@interface MmremindRoot : GPBRootObject
@end

#pragma mark - RemindSyncRequest

typedef GPB_ENUM(RemindSyncRequest_FieldNumber) {
  RemindSyncRequest_FieldNumber_BaseRequest = 1,
  RemindSyncRequest_FieldNumber_Selector = 2,
  RemindSyncRequest_FieldNumber_KeyBuff = 3,
};

@interface RemindSyncRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) uint32_t selector;

@property(nonatomic, readwrite) BOOL hasSelector;
@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinBuffer_t *keyBuff;
/** Test to see if @c keyBuff has been set. */
@property(nonatomic, readwrite) BOOL hasKeyBuff;

@end

#pragma mark - RemindSyncResponse

typedef GPB_ENUM(RemindSyncResponse_FieldNumber) {
  RemindSyncResponse_FieldNumber_BaseResponse = 1,
  RemindSyncResponse_FieldNumber_CmdList = 2,
  RemindSyncResponse_FieldNumber_KeyBuff = 3,
  RemindSyncResponse_FieldNumber_ContinueFlag = 4,
};

@interface RemindSyncResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite, strong, null_resettable) CmdList *cmdList;
/** Test to see if @c cmdList has been set. */
@property(nonatomic, readwrite) BOOL hasCmdList;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinBuffer_t *keyBuff;
/** Test to see if @c keyBuff has been set. */
@property(nonatomic, readwrite) BOOL hasKeyBuff;

@property(nonatomic, readwrite) uint32_t continueFlag;

@property(nonatomic, readwrite) BOOL hasContinueFlag;
@end

#pragma mark - ModRemindCmd

typedef GPB_ENUM(ModRemindCmd_FieldNumber) {
  ModRemindCmd_FieldNumber_RemindId = 1,
  ModRemindCmd_FieldNumber_RemindTime = 2,
  ModRemindCmd_FieldNumber_Flag = 3,
};

@interface ModRemindCmd : GPBMessage

@property(nonatomic, readwrite) uint32_t remindId;

@property(nonatomic, readwrite) BOOL hasRemindId;
@property(nonatomic, readwrite) uint64_t remindTime;

@property(nonatomic, readwrite) BOOL hasRemindTime;
@property(nonatomic, readwrite) uint32_t flag;

@property(nonatomic, readwrite) BOOL hasFlag;
@end

#pragma mark - RemindMember

typedef GPB_ENUM(RemindMember_FieldNumber) {
  RemindMember_FieldNumber_UserName = 1,
};

@interface RemindMember : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *userName;
/** Test to see if @c userName has been set. */
@property(nonatomic, readwrite) BOOL hasUserName;

@end

#pragma mark - RemindItem

typedef GPB_ENUM(RemindItem_FieldNumber) {
  RemindItem_FieldNumber_RemindId = 1,
  RemindItem_FieldNumber_CreateTime = 2,
  RemindItem_FieldNumber_RemindTime = 3,
  RemindItem_FieldNumber_FromUser = 4,
  RemindItem_FieldNumber_ToUserCount = 5,
  RemindItem_FieldNumber_ToUserListArray = 6,
  RemindItem_FieldNumber_Flag = 7,
  RemindItem_FieldNumber_Content = 8,
};

@interface RemindItem : GPBMessage

@property(nonatomic, readwrite) uint32_t remindId;

@property(nonatomic, readwrite) BOOL hasRemindId;
@property(nonatomic, readwrite) uint32_t createTime;

@property(nonatomic, readwrite) BOOL hasCreateTime;
@property(nonatomic, readwrite) uint64_t remindTime;

@property(nonatomic, readwrite) BOOL hasRemindTime;
@property(nonatomic, readwrite, copy, null_resettable) NSString *fromUser;
/** Test to see if @c fromUser has been set. */
@property(nonatomic, readwrite) BOOL hasFromUser;

@property(nonatomic, readwrite) uint32_t toUserCount;

@property(nonatomic, readwrite) BOOL hasToUserCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<RemindMember*> *toUserListArray;
/** The number of items in @c toUserListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger toUserListArray_Count;

@property(nonatomic, readwrite) uint32_t flag;

@property(nonatomic, readwrite) BOOL hasFlag;
@property(nonatomic, readwrite, copy, null_resettable) NSString *content;
/** Test to see if @c content has been set. */
@property(nonatomic, readwrite) BOOL hasContent;

@end

#pragma mark - BatchGetRemindInfoRequest

typedef GPB_ENUM(BatchGetRemindInfoRequest_FieldNumber) {
  BatchGetRemindInfoRequest_FieldNumber_BaseRequest = 1,
  BatchGetRemindInfoRequest_FieldNumber_RemindIdcount = 2,
  BatchGetRemindInfoRequest_FieldNumber_RemindIdlistArray = 3,
};

@interface BatchGetRemindInfoRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) uint32_t remindIdcount;

@property(nonatomic, readwrite) BOOL hasRemindIdcount;
@property(nonatomic, readwrite, strong, null_resettable) GPBUInt32Array *remindIdlistArray;
/** The number of items in @c remindIdlistArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger remindIdlistArray_Count;

@end

#pragma mark - BatchGetRemindInfoResponse

typedef GPB_ENUM(BatchGetRemindInfoResponse_FieldNumber) {
  BatchGetRemindInfoResponse_FieldNumber_BaseResponse = 1,
  BatchGetRemindInfoResponse_FieldNumber_RemindInfoCount = 2,
  BatchGetRemindInfoResponse_FieldNumber_RemindInfoListArray = 3,
};

@interface BatchGetRemindInfoResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) uint32_t remindInfoCount;

@property(nonatomic, readwrite) BOOL hasRemindInfoCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<RemindItem*> *remindInfoListArray;
/** The number of items in @c remindInfoListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger remindInfoListArray_Count;

@end

#pragma mark - AddRemindRequest

typedef GPB_ENUM(AddRemindRequest_FieldNumber) {
  AddRemindRequest_FieldNumber_BaseRequest = 1,
  AddRemindRequest_FieldNumber_ClientId = 2,
  AddRemindRequest_FieldNumber_RemindTime = 3,
  AddRemindRequest_FieldNumber_ToUserCount = 4,
  AddRemindRequest_FieldNumber_ToUserListArray = 5,
  AddRemindRequest_FieldNumber_Content = 6,
};

@interface AddRemindRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite, copy, null_resettable) NSString *clientId;
/** Test to see if @c clientId has been set. */
@property(nonatomic, readwrite) BOOL hasClientId;

@property(nonatomic, readwrite) uint64_t remindTime;

@property(nonatomic, readwrite) BOOL hasRemindTime;
@property(nonatomic, readwrite) uint32_t toUserCount;

@property(nonatomic, readwrite) BOOL hasToUserCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<RemindMember*> *toUserListArray;
/** The number of items in @c toUserListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger toUserListArray_Count;

@property(nonatomic, readwrite, copy, null_resettable) NSString *content;
/** Test to see if @c content has been set. */
@property(nonatomic, readwrite) BOOL hasContent;

@end

#pragma mark - AddRemindResponse

typedef GPB_ENUM(AddRemindResponse_FieldNumber) {
  AddRemindResponse_FieldNumber_BaseResponse = 1,
};

@interface AddRemindResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - DelRemindRequest

typedef GPB_ENUM(DelRemindRequest_FieldNumber) {
  DelRemindRequest_FieldNumber_BaseRequest = 1,
  DelRemindRequest_FieldNumber_RemindId = 2,
};

@interface DelRemindRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) uint32_t remindId;

@property(nonatomic, readwrite) BOOL hasRemindId;
@end

#pragma mark - DelRemindResponse

typedef GPB_ENUM(DelRemindResponse_FieldNumber) {
  DelRemindResponse_FieldNumber_BaseResponse = 1,
};

@interface DelRemindResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
