// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: mmtalk.proto

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
@class DelMemberReq;
@class DelMemberResp;
@class MemberReq;
@class MemberResp;
@class SKBuiltinBuffer_t;
@class SKBuiltinString_t;
@class TalkRelayAddr;
@class TalkRoomMember;
@class TalkStatReportData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MmtalkRoot

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
@interface MmtalkRoot : GPBRootObject
@end

#pragma mark - TalkRoomMember

typedef GPB_ENUM(TalkRoomMember_FieldNumber) {
  TalkRoomMember_FieldNumber_MemberId = 1,
  TalkRoomMember_FieldNumber_UserName = 2,
};

@interface TalkRoomMember : GPBMessage

@property(nonatomic, readwrite) int32_t memberId;

@property(nonatomic, readwrite) BOOL hasMemberId;
@property(nonatomic, readwrite, copy, null_resettable) NSString *userName;
/** Test to see if @c userName has been set. */
@property(nonatomic, readwrite) BOOL hasUserName;

@end

#pragma mark - TalkRelayAddr

typedef GPB_ENUM(TalkRelayAddr_FieldNumber) {
  TalkRelayAddr_FieldNumber_Ip = 1,
  TalkRelayAddr_FieldNumber_Port = 2,
};

@interface TalkRelayAddr : GPBMessage

@property(nonatomic, readwrite) uint32_t ip;

@property(nonatomic, readwrite) BOOL hasIp;
@property(nonatomic, readwrite) uint32_t port;

@property(nonatomic, readwrite) BOOL hasPort;
@end

#pragma mark - EnterTalkRoomReq

typedef GPB_ENUM(EnterTalkRoomReq_FieldNumber) {
  EnterTalkRoomReq_FieldNumber_BaseRequest = 1,
  EnterTalkRoomReq_FieldNumber_ToUsername = 2,
  EnterTalkRoomReq_FieldNumber_Scene = 3,
};

@interface EnterTalkRoomReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite, copy, null_resettable) NSString *toUsername;
/** Test to see if @c toUsername has been set. */
@property(nonatomic, readwrite) BOOL hasToUsername;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - EnterTalkRoomResp

typedef GPB_ENUM(EnterTalkRoomResp_FieldNumber) {
  EnterTalkRoomResp_FieldNumber_BaseResponse = 1,
  EnterTalkRoomResp_FieldNumber_RoomId = 2,
  EnterTalkRoomResp_FieldNumber_RoomKey = 3,
  EnterTalkRoomResp_FieldNumber_MicSeq = 4,
  EnterTalkRoomResp_FieldNumber_MemberNum = 5,
  EnterTalkRoomResp_FieldNumber_MemberListArray = 6,
  EnterTalkRoomResp_FieldNumber_MyRoomMemberId = 7,
  EnterTalkRoomResp_FieldNumber_AddrCount = 8,
  EnterTalkRoomResp_FieldNumber_AddrListArray = 9,
};

@interface EnterTalkRoomResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) int32_t micSeq;

@property(nonatomic, readwrite) BOOL hasMicSeq;
@property(nonatomic, readwrite) int32_t memberNum;

@property(nonatomic, readwrite) BOOL hasMemberNum;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<TalkRoomMember*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@property(nonatomic, readwrite) int32_t myRoomMemberId;

@property(nonatomic, readwrite) BOOL hasMyRoomMemberId;
@property(nonatomic, readwrite) int32_t addrCount;

@property(nonatomic, readwrite) BOOL hasAddrCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<TalkRelayAddr*> *addrListArray;
/** The number of items in @c addrListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger addrListArray_Count;

@end

#pragma mark - ExitTalkRoomReq

typedef GPB_ENUM(ExitTalkRoomReq_FieldNumber) {
  ExitTalkRoomReq_FieldNumber_BaseRequest = 1,
  ExitTalkRoomReq_FieldNumber_RoomId = 2,
  ExitTalkRoomReq_FieldNumber_RoomKey = 3,
  ExitTalkRoomReq_FieldNumber_ToUsername = 4,
  ExitTalkRoomReq_FieldNumber_Scene = 5,
};

@interface ExitTalkRoomReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite, copy, null_resettable) NSString *toUsername;
/** Test to see if @c toUsername has been set. */
@property(nonatomic, readwrite) BOOL hasToUsername;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - ExitTalkRoomResp

typedef GPB_ENUM(ExitTalkRoomResp_FieldNumber) {
  ExitTalkRoomResp_FieldNumber_BaseResponse = 1,
};

@interface ExitTalkRoomResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - TalkMicActionReq

typedef GPB_ENUM(TalkMicActionReq_FieldNumber) {
  TalkMicActionReq_FieldNumber_BaseRequest = 1,
  TalkMicActionReq_FieldNumber_RoomId = 2,
  TalkMicActionReq_FieldNumber_RoomKey = 3,
  TalkMicActionReq_FieldNumber_ActionType = 4,
  TalkMicActionReq_FieldNumber_UpdateTime = 5,
  TalkMicActionReq_FieldNumber_Scene = 6,
};

@interface TalkMicActionReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) uint32_t actionType;

@property(nonatomic, readwrite) BOOL hasActionType;
@property(nonatomic, readwrite) uint32_t updateTime;

@property(nonatomic, readwrite) BOOL hasUpdateTime;
@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - TalkMicActionResp

typedef GPB_ENUM(TalkMicActionResp_FieldNumber) {
  TalkMicActionResp_FieldNumber_BaseResponse = 1,
  TalkMicActionResp_FieldNumber_MicSeq = 2,
  TalkMicActionResp_FieldNumber_ChannelId = 3,
};

@interface TalkMicActionResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) int32_t micSeq;

@property(nonatomic, readwrite) BOOL hasMicSeq;
@property(nonatomic, readwrite) uint32_t channelId;

@property(nonatomic, readwrite) BOOL hasChannelId;
@end

#pragma mark - TalkNoopReq

typedef GPB_ENUM(TalkNoopReq_FieldNumber) {
  TalkNoopReq_FieldNumber_BaseRequest = 1,
  TalkNoopReq_FieldNumber_RoomId = 2,
  TalkNoopReq_FieldNumber_RoomKey = 3,
  TalkNoopReq_FieldNumber_UpdateTime = 4,
  TalkNoopReq_FieldNumber_Scene = 5,
};

@interface TalkNoopReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) uint32_t updateTime;

@property(nonatomic, readwrite) BOOL hasUpdateTime;
@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - TalkNoopResp

typedef GPB_ENUM(TalkNoopResp_FieldNumber) {
  TalkNoopResp_FieldNumber_BaseResponse = 1,
};

@interface TalkNoopResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - GetTalkRoomMemberReq

typedef GPB_ENUM(GetTalkRoomMemberReq_FieldNumber) {
  GetTalkRoomMemberReq_FieldNumber_BaseRequest = 1,
  GetTalkRoomMemberReq_FieldNumber_RoomId = 2,
  GetTalkRoomMemberReq_FieldNumber_RoomKey = 3,
  GetTalkRoomMemberReq_FieldNumber_Scene = 4,
};

@interface GetTalkRoomMemberReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - GetTalkRoomMemberResp

typedef GPB_ENUM(GetTalkRoomMemberResp_FieldNumber) {
  GetTalkRoomMemberResp_FieldNumber_BaseResponse = 1,
  GetTalkRoomMemberResp_FieldNumber_MicSeq = 2,
  GetTalkRoomMemberResp_FieldNumber_MemberNum = 3,
  GetTalkRoomMemberResp_FieldNumber_MemberListArray = 4,
};

@interface GetTalkRoomMemberResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) int32_t micSeq;

@property(nonatomic, readwrite) BOOL hasMicSeq;
@property(nonatomic, readwrite) int32_t memberNum;

@property(nonatomic, readwrite) BOOL hasMemberNum;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<TalkRoomMember*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@end

#pragma mark - TalkInviteReq

typedef GPB_ENUM(TalkInviteReq_FieldNumber) {
  TalkInviteReq_FieldNumber_BaseRequest = 1,
  TalkInviteReq_FieldNumber_RoomId = 2,
  TalkInviteReq_FieldNumber_RoomKey = 3,
  TalkInviteReq_FieldNumber_Scene = 4,
};

@interface TalkInviteReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - TalkInviteResp

typedef GPB_ENUM(TalkInviteResp_FieldNumber) {
  TalkInviteResp_FieldNumber_BaseResponse = 1,
};

@interface TalkInviteResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - TalkStatReportData

typedef GPB_ENUM(TalkStatReportData_FieldNumber) {
  TalkStatReportData_FieldNumber_LogId = 1,
  TalkStatReportData_FieldNumber_StatReport = 2,
};

@interface TalkStatReportData : GPBMessage

@property(nonatomic, readwrite) int32_t logId;

@property(nonatomic, readwrite) BOOL hasLogId;
@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *statReport;
/** Test to see if @c statReport has been set. */
@property(nonatomic, readwrite) BOOL hasStatReport;

@end

#pragma mark - TalkStatReportReq

typedef GPB_ENUM(TalkStatReportReq_FieldNumber) {
  TalkStatReportReq_FieldNumber_BaseRequest = 1,
  TalkStatReportReq_FieldNumber_DataNum = 2,
  TalkStatReportReq_FieldNumber_ReportDataArray = 3,
  TalkStatReportReq_FieldNumber_Scene = 4,
};

@interface TalkStatReportReq : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) int32_t dataNum;

@property(nonatomic, readwrite) BOOL hasDataNum;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<TalkStatReportData*> *reportDataArray;
/** The number of items in @c reportDataArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger reportDataArray_Count;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - TalkStatReportResp

typedef GPB_ENUM(TalkStatReportResp_FieldNumber) {
  TalkStatReportResp_FieldNumber_BaseResponse = 1,
};

@interface TalkStatReportResp : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@end

#pragma mark - CreateTalkRoomRequest

typedef GPB_ENUM(CreateTalkRoomRequest_FieldNumber) {
  CreateTalkRoomRequest_FieldNumber_BaseRequest = 1,
  CreateTalkRoomRequest_FieldNumber_Topic = 2,
  CreateTalkRoomRequest_FieldNumber_MemberCount = 3,
  CreateTalkRoomRequest_FieldNumber_MemberListArray = 4,
  CreateTalkRoomRequest_FieldNumber_Scene = 5,
};

@interface CreateTalkRoomRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *topic;
/** Test to see if @c topic has been set. */
@property(nonatomic, readwrite) BOOL hasTopic;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<MemberReq*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - CreateTalkRoomResponse

typedef GPB_ENUM(CreateTalkRoomResponse_FieldNumber) {
  CreateTalkRoomResponse_FieldNumber_BaseResponse = 1,
  CreateTalkRoomResponse_FieldNumber_Topic = 2,
  CreateTalkRoomResponse_FieldNumber_Pyinitial = 3,
  CreateTalkRoomResponse_FieldNumber_QuanPin = 4,
  CreateTalkRoomResponse_FieldNumber_MemberCount = 5,
  CreateTalkRoomResponse_FieldNumber_MemberListArray = 6,
  CreateTalkRoomResponse_FieldNumber_TalkRoomName = 7,
  CreateTalkRoomResponse_FieldNumber_ImgBuf = 8,
  CreateTalkRoomResponse_FieldNumber_BigHeadImgURL = 9,
  CreateTalkRoomResponse_FieldNumber_SmallHeadImgURL = 10,
  CreateTalkRoomResponse_FieldNumber_RoomId = 11,
  CreateTalkRoomResponse_FieldNumber_RoomKey = 12,
  CreateTalkRoomResponse_FieldNumber_MicSeq = 13,
  CreateTalkRoomResponse_FieldNumber_MyRoomMemberId = 14,
};

@interface CreateTalkRoomResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *topic;
/** Test to see if @c topic has been set. */
@property(nonatomic, readwrite) BOOL hasTopic;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *pyinitial;
/** Test to see if @c pyinitial has been set. */
@property(nonatomic, readwrite) BOOL hasPyinitial;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *quanPin;
/** Test to see if @c quanPin has been set. */
@property(nonatomic, readwrite) BOOL hasQuanPin;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<MemberResp*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *talkRoomName;
/** Test to see if @c talkRoomName has been set. */
@property(nonatomic, readwrite) BOOL hasTalkRoomName;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinBuffer_t *imgBuf;
/** Test to see if @c imgBuf has been set. */
@property(nonatomic, readwrite) BOOL hasImgBuf;

@property(nonatomic, readwrite, copy, null_resettable) NSString *bigHeadImgURL;
/** Test to see if @c bigHeadImgURL has been set. */
@property(nonatomic, readwrite) BOOL hasBigHeadImgURL;

@property(nonatomic, readwrite, copy, null_resettable) NSString *smallHeadImgURL;
/** Test to see if @c smallHeadImgURL has been set. */
@property(nonatomic, readwrite) BOOL hasSmallHeadImgURL;

@property(nonatomic, readwrite) int32_t roomId;

@property(nonatomic, readwrite) BOOL hasRoomId;
@property(nonatomic, readwrite) int64_t roomKey;

@property(nonatomic, readwrite) BOOL hasRoomKey;
@property(nonatomic, readwrite) int32_t micSeq;

@property(nonatomic, readwrite) BOOL hasMicSeq;
@property(nonatomic, readwrite) int32_t myRoomMemberId;

@property(nonatomic, readwrite) BOOL hasMyRoomMemberId;
@end

#pragma mark - AddTalkRoomMemberRequest

typedef GPB_ENUM(AddTalkRoomMemberRequest_FieldNumber) {
  AddTalkRoomMemberRequest_FieldNumber_BaseRequest = 1,
  AddTalkRoomMemberRequest_FieldNumber_MemberCount = 2,
  AddTalkRoomMemberRequest_FieldNumber_MemberListArray = 3,
  AddTalkRoomMemberRequest_FieldNumber_TalkRoomName = 4,
  AddTalkRoomMemberRequest_FieldNumber_Scene = 5,
};

@interface AddTalkRoomMemberRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<MemberReq*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@property(nonatomic, readwrite, strong, null_resettable) SKBuiltinString_t *talkRoomName;
/** Test to see if @c talkRoomName has been set. */
@property(nonatomic, readwrite) BOOL hasTalkRoomName;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - AddTalkRoomMemberResponse

typedef GPB_ENUM(AddTalkRoomMemberResponse_FieldNumber) {
  AddTalkRoomMemberResponse_FieldNumber_BaseResponse = 1,
  AddTalkRoomMemberResponse_FieldNumber_MemberCount = 2,
  AddTalkRoomMemberResponse_FieldNumber_MemberListArray = 3,
};

@interface AddTalkRoomMemberResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<MemberResp*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@end

#pragma mark - DelTalkRoomMemberRequest

typedef GPB_ENUM(DelTalkRoomMemberRequest_FieldNumber) {
  DelTalkRoomMemberRequest_FieldNumber_BaseRequest = 1,
  DelTalkRoomMemberRequest_FieldNumber_MemberCount = 2,
  DelTalkRoomMemberRequest_FieldNumber_MemberListArray = 3,
  DelTalkRoomMemberRequest_FieldNumber_TalkRoomName = 4,
  DelTalkRoomMemberRequest_FieldNumber_Scene = 5,
};

@interface DelTalkRoomMemberRequest : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseRequest *baseRequest;
/** Test to see if @c baseRequest has been set. */
@property(nonatomic, readwrite) BOOL hasBaseRequest;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<DelMemberReq*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@property(nonatomic, readwrite, copy, null_resettable) NSString *talkRoomName;
/** Test to see if @c talkRoomName has been set. */
@property(nonatomic, readwrite) BOOL hasTalkRoomName;

@property(nonatomic, readwrite) uint32_t scene;

@property(nonatomic, readwrite) BOOL hasScene;
@end

#pragma mark - DelTalkRoomMemberResponse

typedef GPB_ENUM(DelTalkRoomMemberResponse_FieldNumber) {
  DelTalkRoomMemberResponse_FieldNumber_BaseResponse = 1,
  DelTalkRoomMemberResponse_FieldNumber_MemberCount = 2,
  DelTalkRoomMemberResponse_FieldNumber_MemberListArray = 3,
};

@interface DelTalkRoomMemberResponse : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) BaseResponse *baseResponse;
/** Test to see if @c baseResponse has been set. */
@property(nonatomic, readwrite) BOOL hasBaseResponse;

@property(nonatomic, readwrite) uint32_t memberCount;

@property(nonatomic, readwrite) BOOL hasMemberCount;
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<DelMemberResp*> *memberListArray;
/** The number of items in @c memberListArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger memberListArray_Count;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
