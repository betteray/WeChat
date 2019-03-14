// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: mmthinker.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Mmthinker.pbobjc.h"
#import "Mmbuiltintype.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - MmthinkerRoot

@implementation MmthinkerRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - MmthinkerRoot_FileDescriptor

static GPBFileDescriptor *MmthinkerRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"micromsg"
                                                     syntax:GPBFileSyntaxProto2];
  }
  return descriptor;
}

#pragma mark - SubTypeVector

@implementation SubTypeVector

@dynamic hasSubType, subType;
@dynamic hasKeyVersion, keyVersion;
@dynamic hasResVersion, resVersion;
@dynamic hasEid, eid;

typedef struct SubTypeVector__storage_ {
  uint32_t _has_storage_[1];
  int32_t subType;
  int32_t keyVersion;
  int32_t resVersion;
  int32_t eid;
} SubTypeVector__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "subType",
        .dataTypeSpecific.className = NULL,
        .number = SubTypeVector_FieldNumber_SubType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SubTypeVector__storage_, subType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "keyVersion",
        .dataTypeSpecific.className = NULL,
        .number = SubTypeVector_FieldNumber_KeyVersion,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(SubTypeVector__storage_, keyVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "resVersion",
        .dataTypeSpecific.className = NULL,
        .number = SubTypeVector_FieldNumber_ResVersion,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(SubTypeVector__storage_, resVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "eid",
        .dataTypeSpecific.className = NULL,
        .number = SubTypeVector_FieldNumber_Eid,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(SubTypeVector__storage_, eid),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SubTypeVector class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SubTypeVector__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\003\001\007\000\002\n\000\003\n\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - ResID

@implementation ResID

@dynamic hasType, type;
@dynamic subTypeVectorArray, subTypeVectorArray_Count;

typedef struct ResID__storage_ {
  uint32_t _has_storage_[1];
  int32_t type;
  NSMutableArray *subTypeVectorArray;
} ResID__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "type",
        .dataTypeSpecific.className = NULL,
        .number = ResID_FieldNumber_Type,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(ResID__storage_, type),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "subTypeVectorArray",
        .dataTypeSpecific.className = GPBStringifySymbol(SubTypeVector),
        .number = ResID_FieldNumber_SubTypeVectorArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(ResID__storage_, subTypeVectorArray),
        .flags = (GPBFieldFlags)(GPBFieldRepeated | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ResID class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(ResID__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\002\000subTypeVector\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - ResIDWrap

@implementation ResIDWrap

@dynamic resIdArray, resIdArray_Count;

typedef struct ResIDWrap__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *resIdArray;
} ResIDWrap__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "resIdArray",
        .dataTypeSpecific.className = GPBStringifySymbol(ResID),
        .number = ResIDWrap_FieldNumber_ResIdArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(ResIDWrap__storage_, resIdArray),
        .flags = (GPBFieldFlags)(GPBFieldRepeated | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ResIDWrap class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(ResIDWrap__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\000resId\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - CheckResUpdateRequest

@implementation CheckResUpdateRequest

@dynamic hasBaseRequest, baseRequest;
@dynamic hasWrap, wrap;

typedef struct CheckResUpdateRequest__storage_ {
  uint32_t _has_storage_[1];
  BaseRequest *baseRequest;
  ResIDWrap *wrap;
} CheckResUpdateRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "baseRequest",
        .dataTypeSpecific.className = GPBStringifySymbol(BaseRequest),
        .number = CheckResUpdateRequest_FieldNumber_BaseRequest,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(CheckResUpdateRequest__storage_, baseRequest),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "wrap",
        .dataTypeSpecific.className = GPBStringifySymbol(ResIDWrap),
        .number = CheckResUpdateRequest_FieldNumber_Wrap,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(CheckResUpdateRequest__storage_, wrap),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[CheckResUpdateRequest class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(CheckResUpdateRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\013\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - CheckResUpdateResponse

@implementation CheckResUpdateResponse

@dynamic hasBaseResponse, baseResponse;

typedef struct CheckResUpdateResponse__storage_ {
  uint32_t _has_storage_[1];
  BaseResponse *baseResponse;
} CheckResUpdateResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "baseResponse",
        .dataTypeSpecific.className = GPBStringifySymbol(BaseResponse),
        .number = CheckResUpdateResponse_FieldNumber_BaseResponse,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(CheckResUpdateResponse__storage_, baseResponse),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[CheckResUpdateResponse class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(CheckResUpdateResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\014\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - EncryptKey

@implementation EncryptKey

@dynamic hasKey, key;

typedef struct EncryptKey__storage_ {
  uint32_t _has_storage_[1];
  SKBuiltinBuffer_t *key;
} EncryptKey__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "key",
        .dataTypeSpecific.className = GPBStringifySymbol(SKBuiltinBuffer_t),
        .number = EncryptKey_FieldNumber_Key,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(EncryptKey__storage_, key),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[EncryptKey class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(EncryptKey__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - SecEncryptCheckResUpdateRequest

@implementation SecEncryptCheckResUpdateRequest

@dynamic hasAesEncryptKey, aesEncryptKey;
@dynamic hasReq, req;

typedef struct SecEncryptCheckResUpdateRequest__storage_ {
  uint32_t _has_storage_[1];
  EncryptKey *aesEncryptKey;
  CheckResUpdateRequest *req;
} SecEncryptCheckResUpdateRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "aesEncryptKey",
        .dataTypeSpecific.className = GPBStringifySymbol(EncryptKey),
        .number = SecEncryptCheckResUpdateRequest_FieldNumber_AesEncryptKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SecEncryptCheckResUpdateRequest__storage_, aesEncryptKey),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "req",
        .dataTypeSpecific.className = GPBStringifySymbol(CheckResUpdateRequest),
        .number = SecEncryptCheckResUpdateRequest_FieldNumber_Req,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(SecEncryptCheckResUpdateRequest__storage_, req),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SecEncryptCheckResUpdateRequest class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SecEncryptCheckResUpdateRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\r\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Resource

@implementation Resource

@dynamic hasSubType, subType;
@dynamic hasInfo, info;
@dynamic hasKey, key;
@dynamic hasOper, oper;
@dynamic hasReportId, reportId;
@dynamic hasSampleId, sampleId;
@dynamic hasExpireTime, expireTime;
@dynamic hasRetryTime, retryTime;
@dynamic hasEid, eid;
@dynamic hasDownloadNetType, downloadNetType;
@dynamic hasRetryInterval, retryInterval;
@dynamic hasPriority, priority;

typedef struct Resource__storage_ {
  uint32_t _has_storage_[1];
  uint32_t subType;
  uint32_t oper;
  uint32_t reportId;
  uint32_t expireTime;
  uint32_t retryTime;
  uint32_t eid;
  uint32_t downloadNetType;
  uint32_t retryInterval;
  uint32_t priority;
  Resource_ResourceMeta *info;
  Resource_ResourceKey *key;
  NSString *sampleId;
} Resource__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "subType",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_SubType,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Resource__storage_, subType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "info",
        .dataTypeSpecific.className = GPBStringifySymbol(Resource_ResourceMeta),
        .number = Resource_FieldNumber_Info,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Resource__storage_, info),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "key",
        .dataTypeSpecific.className = GPBStringifySymbol(Resource_ResourceKey),
        .number = Resource_FieldNumber_Key,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(Resource__storage_, key),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "oper",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_Oper,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(Resource__storage_, oper),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "reportId",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_ReportId,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(Resource__storage_, reportId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "sampleId",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_SampleId,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(Resource__storage_, sampleId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "expireTime",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_ExpireTime,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(Resource__storage_, expireTime),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "retryTime",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_RetryTime,
        .hasIndex = 7,
        .offset = (uint32_t)offsetof(Resource__storage_, retryTime),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "eid",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_Eid,
        .hasIndex = 8,
        .offset = (uint32_t)offsetof(Resource__storage_, eid),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "downloadNetType",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_DownloadNetType,
        .hasIndex = 9,
        .offset = (uint32_t)offsetof(Resource__storage_, downloadNetType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "retryInterval",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_RetryInterval,
        .hasIndex = 10,
        .offset = (uint32_t)offsetof(Resource__storage_, retryInterval),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "priority",
        .dataTypeSpecific.className = NULL,
        .number = Resource_FieldNumber_Priority,
        .hasIndex = 11,
        .offset = (uint32_t)offsetof(Resource__storage_, priority),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Resource class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Resource__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\007\001\007\000\005\010\000\006\010\000\007\n\000\010\t\000\n\017\000\013\r\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Resource_ResourceMeta

@implementation Resource_ResourceMeta

@dynamic hasMd5, md5;
@dynamic hasResVersion, resVersion;
@dynamic hasURL, URL;
@dynamic hasFileFlag, fileFlag;
@dynamic hasData_p, data_p;
@dynamic hasOriginalMd5, originalMd5;
@dynamic hasFileSize, fileSize;

typedef struct Resource_ResourceMeta__storage_ {
  uint32_t _has_storage_[1];
  uint32_t resVersion;
  uint32_t fileFlag;
  uint32_t fileSize;
  NSString *md5;
  NSString *URL;
  NSData *data_p;
  NSString *originalMd5;
} Resource_ResourceMeta__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "md5",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_Md5,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, md5),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "resVersion",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_ResVersion,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, resVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "URL",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_URL,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, URL),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "fileFlag",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_FileFlag,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, fileFlag),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "data_p",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_Data_p,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, data_p),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "originalMd5",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_OriginalMd5,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, originalMd5),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "fileSize",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceMeta_FieldNumber_FileSize,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(Resource_ResourceMeta__storage_, fileSize),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Resource_ResourceMeta class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Resource_ResourceMeta__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\005\002\n\000\003!!!\000\004\010\000\007\013\000\010\010\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    [localDescriptor setupContainingMessageClassName:GPBStringifySymbol(Resource)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Resource_ResourceKey

@implementation Resource_ResourceKey

@dynamic hasKeyVersion, keyVersion;
@dynamic hasResKey, resKey;

typedef struct Resource_ResourceKey__storage_ {
  uint32_t _has_storage_[1];
  uint32_t keyVersion;
  NSString *resKey;
} Resource_ResourceKey__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "keyVersion",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceKey_FieldNumber_KeyVersion,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Resource_ResourceKey__storage_, keyVersion),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "resKey",
        .dataTypeSpecific.className = NULL,
        .number = Resource_ResourceKey_FieldNumber_ResKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Resource_ResourceKey__storage_, resKey),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Resource_ResourceKey class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Resource_ResourceKey__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\002\001\n\000\002\006\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    [localDescriptor setupContainingMessageClassName:GPBStringifySymbol(Resource)];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - ResourceType

@implementation ResourceType

@dynamic hasType, type;
@dynamic resourcesArray, resourcesArray_Count;

typedef struct ResourceType__storage_ {
  uint32_t _has_storage_[1];
  uint32_t type;
  NSMutableArray *resourcesArray;
} ResourceType__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "type",
        .dataTypeSpecific.className = NULL,
        .number = ResourceType_FieldNumber_Type,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(ResourceType__storage_, type),
        .flags = GPBFieldRequired,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "resourcesArray",
        .dataTypeSpecific.className = GPBStringifySymbol(Resource),
        .number = ResourceType_FieldNumber_ResourcesArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(ResourceType__storage_, resourcesArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ResourceType class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(ResourceType__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - SecEncryptCheckResUpdateResponse

@implementation SecEncryptCheckResUpdateResponse

@dynamic hasBaseResponse, baseResponse;
@dynamic resourceTypeArray, resourceTypeArray_Count;

typedef struct SecEncryptCheckResUpdateResponse__storage_ {
  uint32_t _has_storage_[1];
  BaseResponse *baseResponse;
  NSMutableArray *resourceTypeArray;
} SecEncryptCheckResUpdateResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "baseResponse",
        .dataTypeSpecific.className = GPBStringifySymbol(BaseResponse),
        .number = SecEncryptCheckResUpdateResponse_FieldNumber_BaseResponse,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SecEncryptCheckResUpdateResponse__storage_, baseResponse),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "resourceTypeArray",
        .dataTypeSpecific.className = GPBStringifySymbol(ResourceType),
        .number = SecEncryptCheckResUpdateResponse_FieldNumber_ResourceTypeArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(SecEncryptCheckResUpdateResponse__storage_, resourceTypeArray),
        .flags = (GPBFieldFlags)(GPBFieldRepeated | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SecEncryptCheckResUpdateResponse class]
                                     rootClass:[MmthinkerRoot class]
                                          file:MmthinkerRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SecEncryptCheckResUpdateResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\002\001\014\000\002\000resourceType\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
