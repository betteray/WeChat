//
//  json2pb.m
//  xcaller
//
//  Created by rannger on 2017/8/30.
//  Copyright © 2017年 rannger. All rights reserved.
//

#import "json2pb.h"
#import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>

static NSNumber* __REAL(double value) {
  return [NSNumber numberWithDouble:value];
}
static NSNumber* __INTEGER(int64_t value) {
  return [NSNumber numberWithLongLong:value];
}
static NSNumber* __BOOL(bool value) {
  return [NSNumber numberWithBool:value];
}
static id<NSObject> FieldToJson(GPBMessage* msg, GPBFieldDescriptor *field, size_t index);
static id<NSObject> MessageToJson(GPBMessage* msg);
static void JsonToMessage(GPBMessage* msg, id<NSObject> root);
static void JsonToField(GPBMessage* msg, GPBFieldDescriptor* field, id<NSObject> jf);

static id<NSObject> FieldToJson(GPBMessage* msg, GPBFieldDescriptor *field, size_t index) {
  BOOL repeated = ([field fieldType] == GPBFieldTypeRepeated);
  id<NSObject> jf = nil;
  
  switch ([field dataType]) {
#define __CASE(type, ctype, fmt, arraytype, sfunc)                     \
case type: {                                                           \
  ctype value;                                                         \
  if (repeated) {                                                      \
    arraytype *array = GPBGetMessageRepeatedField(msg, field);         \
    value = [array valueAtIndex:index];                                \
  } else {                                                             \
    value = sfunc(msg, field);                                         \
  }                                                                    \
  jf = fmt(value);                                                     \
  break;                                                               \
}
      
      __CASE(GPBDataTypeDouble, double, __REAL,GPBDoubleArray,GPBGetMessageDoubleField);
      __CASE(GPBDataTypeFloat, double, __REAL,GPBFloatArray,GPBGetMessageFloatField);
      __CASE(GPBDataTypeInt64, uint64_t, __INTEGER,GPBInt64Array,GPBGetMessageInt64Field);
      __CASE(GPBDataTypeSFixed64, uint64_t, __INTEGER,GPBInt64Array,GPBGetMessageInt64Field);
      __CASE(GPBDataTypeSInt64, uint64_t, __INTEGER,GPBInt64Array,GPBGetMessageInt64Field);
      __CASE(GPBDataTypeUInt64, uint64_t, __INTEGER,GPBUInt64Array,GPBGetMessageUInt64Field);
      __CASE(GPBDataTypeFixed64, uint64_t, __INTEGER,GPBUInt64Array,GPBGetMessageUInt64Field);
      __CASE(GPBDataTypeInt32, uint64_t, __INTEGER,GPBInt32Array,GPBGetMessageInt32Field);
      __CASE(GPBDataTypeSInt32, uint64_t, __INTEGER,GPBInt32Array,GPBGetMessageInt32Field);
      __CASE(GPBDataTypeSFixed32, uint64_t, __INTEGER,GPBInt32Array,GPBGetMessageInt32Field);
      __CASE(GPBDataTypeUInt32, uint64_t, __INTEGER,GPBUInt32Array,GPBGetMessageUInt32Field);
      __CASE(GPBDataTypeFixed32, uint64_t, __INTEGER,GPBUInt32Array,GPBGetMessageUInt32Field);
      __CASE(GPBDataTypeBool, bool, __BOOL,GPBBoolArray,GPBGetMessageBoolField);
#undef __CASE
    case GPBDataTypeString:
    {
      NSString* value = nil;
      if (repeated) {
        NSArray<NSString*>* array = GPBGetMessageRepeatedField(msg,field);
        value = array[index];
      } else {
        value = GPBGetMessageStringField(msg, field);
      }
      
      jf = [NSString stringWithString:value];
    }
      break;
    case GPBDataTypeBytes:
    {
      NSData* data = nil;
      if (repeated) {
        NSArray<NSData*>* array = GPBGetMessageRepeatedField(msg,field);
        data = array[index];
      } else {
        data = GPBGetMessageBytesField(msg,field);
      }
      jf =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
      break;
    case GPBDataTypeMessage:
    {
      GPBMessage* mesg = nil;
      if (repeated) {
        NSArray<GPBMessage*>* array = GPBGetMessageRepeatedField(msg, field);
        mesg = array[index];
      } else {
        mesg = GPBGetMessageMessageField(msg, field);
      }
      
      jf = MessageToJson(mesg);
    }
      break;
    case GPBDataTypeEnum:
    {
      int32_t value = 0;
      if (repeated) {
        GPBEnumArray* array = GPBGetMessageRepeatedField(msg, field);
        value = [array valueAtIndex:index];
      } else {
        value = GPBGetMessageEnumField(msg, field);
      }
      jf = __INTEGER(value);
    }
      break;
    default:
      break;
  }
  
  return jf;
}

static id<NSObject> MessageToJson(GPBMessage* msg) {
  GPBDescriptor* d = [msg descriptor];
  NSMutableDictionary* root = [NSMutableDictionary dictionaryWithCapacity:10];
  
  for (GPBFieldDescriptor* field in [d fields]) {
    id<NSObject> jf = nil;
    if ([field fieldType] == GPBFieldTypeRepeated) {
      NSArray* array = GPBGetMessageRepeatedField(msg, field);
      if ([array respondsToSelector:@selector(count)]&& [array count]!=0) {
        NSMutableArray* list = [NSMutableArray arrayWithCapacity:[array count]];
        for (int i = 0; i<[array count]; ++i) {
          id<NSObject> res = FieldToJson(msg, field, i);
          if (nil!=res) {
            [list addObject:res];
          }
        }
        jf = list;
      }
    } else if (GPBGetHasIvarField(msg, field)) {
      jf = FieldToJson(msg, field, 0);
    } else {
      continue;
    }
    NSString* name = [field textFormatName];
    if (nil==jf)
      continue;
    [root setObject:jf forKey:name];
  }
  
  return root;
}


static void JsonToField(GPBMessage* msg, GPBFieldDescriptor* field, id<NSObject> jf) {
  BOOL repeated = ([field fieldType] == GPBFieldTypeRepeated);
  switch ([field dataType]) {
      
#define __SET_OR_ADD(sfunc, value, arraytype)                             \
do {                                                                      \
  if (repeated) {                                                         \
    arraytype *array = GPBGetMessageRepeatedField(msg, field);            \
    if ([array respondsToSelector:@selector(addValue:)]) {                \
      [array addValue:value];                                             \
    } else {                                                              \
      assert(0);                                                          \
    }                                                                     \
  } else {                                                                \
    sfunc(msg, field, value);                                             \
  }                                                                       \
} while (0);
#define __CASE(type, ctype, fmt, arraytype, sfunc)                        \
case type: {                                                              \
  NSNumber* js = (NSNumber*)jf;                                           \
  ctype value = [js fmt];                                                 \
  __SET_OR_ADD(sfunc, value, arraytype);                                  \
  break;                                                                  \
}
      
      __CASE(GPBDataTypeDouble, double, doubleValue,GPBDoubleArray,GPBSetMessageDoubleField);
      __CASE(GPBDataTypeFloat, double, doubleValue,GPBFloatArray,GPBSetMessageFloatField);
      __CASE(GPBDataTypeInt64, int64_t,longLongValue, GPBInt64Array,GPBSetMessageInt64Field);
      __CASE(GPBDataTypeSFixed64,int64_t, longLongValue, GPBInt64Array,GPBSetMessageInt64Field);
      __CASE(GPBDataTypeSInt64,int64_t, longLongValue, GPBInt64Array,GPBSetMessageInt64Field);
      __CASE(GPBDataTypeUInt64,int64_t, longLongValue, GPBUInt64Array,GPBSetMessageUInt64Field);
      __CASE(GPBDataTypeFixed64,int64_t, longLongValue, GPBUInt64Array,GPBSetMessageUInt64Field);
      __CASE(GPBDataTypeInt32,int64_t, longLongValue, GPBInt32Array,GPBSetMessageInt32Field);
      __CASE(GPBDataTypeSInt32,int64_t, longLongValue, GPBInt32Array,GPBSetMessageInt32Field);
      __CASE(GPBDataTypeSFixed32,int64_t, longLongValue, GPBInt32Array,GPBSetMessageInt32Field);
      __CASE(GPBDataTypeUInt32,int64_t, longLongValue, GPBUInt32Array,GPBSetMessageUInt32Field);
      __CASE(GPBDataTypeFixed32,int64_t, longLongValue, GPBUInt32Array,GPBSetMessageUInt32Field);
      __CASE(GPBDataTypeBool, BOOL, boolValue,GPBBoolArray,GPBSetMessageBoolField);
#undef __SET_OR_ADD
#undef __CASE

#define __SET_OR_ADD(sfunc, value, arraytype)                         \
do {                                                                  \
  if (repeated) {                                                     \
    arraytype *array = GPBGetMessageRepeatedField(msg, field);        \
    if ([array respondsToSelector:@selector(addObject:)]) {           \
      [array addObject:value];                                        \
    } else {                                                          \
      assert(0);                                                      \
    }                                                                 \
  } else {                                                            \
    sfunc(msg, field, value);                                         \
  }                                                                   \
} while (0);

    case GPBDataTypeString:
    {
      if (![jf isKindOfClass:[NSString class]]) {
        NSCAssert(NO,@"Not a string");
      }
      NSString* string = (NSString*)jf;
      __SET_OR_ADD(GPBSetMessageStringField, string, NSMutableArray);
    }
      break;
    case GPBDataTypeBytes:
    {
      if (![jf isKindOfClass:[NSString class]]) {
        NSCAssert(NO,@"Not a string");
      }
      NSString* string = (NSString*)jf;
      NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
      __SET_OR_ADD(GPBSetMessageBytesField, decodedData, NSMutableArray);
    }
      break;
    case GPBDataTypeMessage:
    {
      GPBMessage* mf = nil;
      if (repeated) {
        mf = [[field.msgClass alloc] init];
      } else {
        mf = GPBGetMessageMessageField(msg, field);
      }
      JsonToMessage(mf, jf);
      if (repeated) {
        NSMutableArray* array = GPBGetMessageRepeatedField(msg, field);
        [array addObject:mf];
      }
    }
      break;
    case GPBDataTypeEnum:
    {
      GPBEnumDescriptor* ed = field.enumDescriptor;
      int32_t value = 0;
      if ([jf isKindOfClass:[NSNumber class]]) {
        NSNumber* js = (NSNumber*)jf;
        value = [js intValue];
      } else if ([jf isKindOfClass:[NSString class]]) {
        
        BOOL ret = [ed getValue:&value
          forEnumTextFormatName:(NSString*)jf];
        assert(ret);
      } else {
        NSCAssert(NO,@"Not an integer or string");
      }
      if (repeated) {
        GPBEnumArray* array = GPBGetMessageRepeatedField(msg, field);
        [array addRawValue:value];
      } else {
        GPBSetMessageEnumField(msg, field,value);
      }
    }
      break;
    default:
      break;
  }
}

static void JsonToMessage(GPBMessage* msg, id<NSObject> root) {
  GPBDescriptor* d = [msg descriptor];
  
  if (nil==d) {
    NSCAssert(NO,@"No descriptor or reflection");
  }
  
  for (NSString* name in [(NSDictionary*)root allKeys]) {
    id<NSObject> jf = [(NSDictionary*)root objectForKey:name];
    
    GPBFieldDescriptor* field = [d fieldWithName:name];
    if (!field) {
      for (GPBFieldDescriptor* f in [d fields]) {
        if ([[f textFormatName] isEqualToString:name]) {
          field = f;
          break;
        }
      }
    }
    
    if (!field) {
      NSCAssert(NO,@"No descriptor or reflection");
    }
    
    if ([field fieldType] == GPBFieldTypeRepeated) {
      if (![jf isKindOfClass:[NSArray class]])
        [NSException exceptionWithName:@"Not array" reason:@"Not array" userInfo:nil];
      for (NSInteger j = 0; j<[(NSArray*)jf count]; ++j) {
        JsonToField(msg, field, [(NSArray*)jf objectAtIndex:j]);
      }
    } else {
      JsonToField(msg, field, jf);
    }
  }
}

@implementation GPBMessage (JSON)

+ (void)fromJson:(GPBMessage*)msg data:(NSData*)data {
  NSError* error = nil;
  id<NSObject> root = [NSJSONSerialization JSONObjectWithData:data
                                                      options:kNilOptions
                                                        error:&error];
  
  if (nil!=error) {
    NSAssert(NO,@"Load failed");
  }

  JsonToMessage(msg, root);
}

+ (NSData*)toJson:(GPBMessage*)msg {
  id<NSObject> root = [self toJsonObj:msg];
  NSAssert([NSJSONSerialization isValidJSONObject:root], @"Not Json");
  NSData* data = [NSJSONSerialization dataWithJSONObject:root options:kNilOptions error:nil];
  return data;
}

+ (id)toJsonObj:(GPBMessage*)msg {
  id<NSObject> root = MessageToJson(msg);
  return root;
}

- (instancetype)initWithJson:(NSData*)data {
  self = [self init];
  if (self) {
    [GPBMessage fromJson:self data:data];
  }
  
  return self;
}

- (NSData*)toJson {
  return [GPBMessage toJson:self];
}

- (id)jsonObject {
  return [GPBMessage toJsonObj:self];
}
@end


