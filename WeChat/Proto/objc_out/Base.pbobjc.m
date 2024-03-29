// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: base.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Base.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - BaseRoot

@implementation BaseRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - BaseRoot_FileDescriptor

static GPBFileDescriptor *BaseRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto2];
  }
  return descriptor;
}

#pragma mark - SKBuiltinBuffer_t

@implementation SKBuiltinBuffer_t

@dynamic hasILen, iLen;
@dynamic hasBuffer, buffer;

typedef struct SKBuiltinBuffer_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t iLen;
  NSData *buffer;
} SKBuiltinBuffer_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "iLen",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinBuffer_t_FieldNumber_ILen,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinBuffer_t__storage_, iLen),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "buffer",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinBuffer_t_FieldNumber_Buffer,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(SKBuiltinBuffer_t__storage_, buffer),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinBuffer_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinBuffer_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinChar_t

@implementation SKBuiltinChar_t

@dynamic hasIVal, iVal;

typedef struct SKBuiltinChar_t__storage_ {
  uint32_t _has_storage_[1];
  int32_t iVal;
} SKBuiltinChar_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "iVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinChar_t_FieldNumber_IVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinChar_t__storage_, iVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinChar_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinChar_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinDouble64_t

@implementation SKBuiltinDouble64_t

@dynamic hasDVal, dVal;

typedef struct SKBuiltinDouble64_t__storage_ {
  uint32_t _has_storage_[1];
  double dVal;
} SKBuiltinDouble64_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "dVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinDouble64_t_FieldNumber_DVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinDouble64_t__storage_, dVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeDouble,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinDouble64_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinDouble64_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinFloat32_t

@implementation SKBuiltinFloat32_t

@dynamic hasFVal, fVal;

typedef struct SKBuiltinFloat32_t__storage_ {
  uint32_t _has_storage_[1];
  float fVal;
} SKBuiltinFloat32_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinFloat32_t_FieldNumber_FVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinFloat32_t__storage_, fVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeFloat,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinFloat32_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinFloat32_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinInt16_t

@implementation SKBuiltinInt16_t

@dynamic hasIVal, iVal;

typedef struct SKBuiltinInt16_t__storage_ {
  uint32_t _has_storage_[1];
  int32_t iVal;
} SKBuiltinInt16_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "iVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinInt16_t_FieldNumber_IVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinInt16_t__storage_, iVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinInt16_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinInt16_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinInt32_t

@implementation SKBuiltinInt32_t

@dynamic hasIVal, iVal;

typedef struct SKBuiltinInt32_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t iVal;
} SKBuiltinInt32_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "iVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinInt32_t_FieldNumber_IVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinInt32_t__storage_, iVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinInt32_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinInt32_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinInt64_t

@implementation SKBuiltinInt64_t

@dynamic hasLlVal, llVal;

typedef struct SKBuiltinInt64_t__storage_ {
  uint32_t _has_storage_[1];
  int64_t llVal;
} SKBuiltinInt64_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "llVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinInt64_t_FieldNumber_LlVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinInt64_t__storage_, llVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinInt64_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinInt64_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\005\000";
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

#pragma mark - SKBuiltinInt8_t

@implementation SKBuiltinInt8_t

@dynamic hasIVal, iVal;

typedef struct SKBuiltinInt8_t__storage_ {
  uint32_t _has_storage_[1];
  int32_t iVal;
} SKBuiltinInt8_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "iVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinInt8_t_FieldNumber_IVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinInt8_t__storage_, iVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinInt8_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinInt8_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\004\000";
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

#pragma mark - SKBuiltinString_t

@implementation SKBuiltinString_t

@dynamic hasString, string;

typedef struct SKBuiltinString_t__storage_ {
  uint32_t _has_storage_[1];
  NSString *string;
} SKBuiltinString_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "string",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinString_t_FieldNumber_String,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinString_t__storage_, string),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinString_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinString_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - SKBuiltinUchar_t

@implementation SKBuiltinUchar_t

@dynamic hasUiVal, uiVal;

typedef struct SKBuiltinUchar_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t uiVal;
} SKBuiltinUchar_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "uiVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinUchar_t_FieldNumber_UiVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinUchar_t__storage_, uiVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinUchar_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinUchar_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\005\000";
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

#pragma mark - SKBuiltinUint16_t

@implementation SKBuiltinUint16_t

@dynamic hasUiVal, uiVal;

typedef struct SKBuiltinUint16_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t uiVal;
} SKBuiltinUint16_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "uiVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinUint16_t_FieldNumber_UiVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinUint16_t__storage_, uiVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinUint16_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinUint16_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\005\000";
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

#pragma mark - SKBuiltinUint32_t

@implementation SKBuiltinUint32_t

@dynamic hasUiVal, uiVal;

typedef struct SKBuiltinUint32_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t uiVal;
} SKBuiltinUint32_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "uiVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinUint32_t_FieldNumber_UiVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinUint32_t__storage_, uiVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinUint32_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinUint32_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\005\000";
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

#pragma mark - SKBuiltinUint64_t

@implementation SKBuiltinUint64_t

@dynamic hasUllVal, ullVal;

typedef struct SKBuiltinUint64_t__storage_ {
  uint32_t _has_storage_[1];
  uint64_t ullVal;
} SKBuiltinUint64_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "ullVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinUint64_t_FieldNumber_UllVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinUint64_t__storage_, ullVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt64,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinUint64_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinUint64_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\006\000";
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

#pragma mark - SKBuiltinUint8_t

@implementation SKBuiltinUint8_t

@dynamic hasUiVal, uiVal;

typedef struct SKBuiltinUint8_t__storage_ {
  uint32_t _has_storage_[1];
  uint32_t uiVal;
} SKBuiltinUint8_t__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "uiVal",
        .dataTypeSpecific.className = NULL,
        .number = SKBuiltinUint8_t_FieldNumber_UiVal,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(SKBuiltinUint8_t__storage_, uiVal),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SKBuiltinUint8_t class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SKBuiltinUint8_t__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\005\000";
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

#pragma mark - BaseRequest

@implementation BaseRequest

@dynamic hasSessionKey, sessionKey;
@dynamic hasUin, uin;
@dynamic hasDeviceId, deviceId;
@dynamic hasClientVersion, clientVersion;
@dynamic hasDeviceType, deviceType;
@dynamic hasScene, scene;

typedef struct BaseRequest__storage_ {
  uint32_t _has_storage_[1];
  uint32_t uin;
  int32_t clientVersion;
  uint32_t scene;
  NSData *sessionKey;
  NSData *deviceId;
  NSData *deviceType;
} BaseRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "sessionKey",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_SessionKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, sessionKey),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "uin",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_Uin,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, uin),
        .flags = GPBFieldRequired,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "deviceId",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_DeviceId,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, deviceId),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "clientVersion",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_ClientVersion,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, clientVersion),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "deviceType",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_DeviceType,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "scene",
        .dataTypeSpecific.className = NULL,
        .number = BaseRequest_FieldNumber_Scene,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(BaseRequest__storage_, scene),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BaseRequest class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BaseRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\004\001\n\000\003\010\000\004\r\000\005\n\000";
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

#pragma mark - BaseResponse

@implementation BaseResponse

@dynamic hasRet, ret;
@dynamic hasErrMsg, errMsg;

typedef struct BaseResponse__storage_ {
  uint32_t _has_storage_[1];
  int32_t ret;
  SKBuiltinString_t *errMsg;
} BaseResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "ret",
        .dataTypeSpecific.className = NULL,
        .number = BaseResponse_FieldNumber_Ret,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BaseResponse__storage_, ret),
        .flags = GPBFieldRequired,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "errMsg",
        .dataTypeSpecific.className = GPBStringifySymbol(SKBuiltinString_t),
        .number = BaseResponse_FieldNumber_ErrMsg,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BaseResponse__storage_, errMsg),
        .flags = (GPBFieldFlags)(GPBFieldRequired | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BaseResponse class]
                                     rootClass:[BaseRoot class]
                                          file:BaseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BaseResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\002\006\000";
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
