/**
 * Tencent is pleased to support the open source community by making Tars available.
 *
 * Copyright (C) 2016THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except 
 * in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed 
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the 
 * specific language governing permissions and limitations under the License.
 */

//
//  TarsObjectV2.h
//
//  Created by 壬俊 易 on 12-3-13.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "TarsObject.h"

/**
 * TarsObjectV2 充分利用Object-C的动态特定，提供更智能(自动化)的Tars打包解包方案
 * 
 * 如果一个类要支持Tars编解码，只需要继承TarsObjectV2类，并且使用JV2_PROP_**宏来定义其属性，该
 * 属性的get方法和set方法分别为：Tars_name, setTars_name:
 *
 * 对于NSArray和NSDictionary(即Tars中的Vector和Map)，需要用到附加信息ext编码。附加信息编码
 * 字符串的第一个字母为'V'或者‘M’或者'O'，分别代表Vector、Map和支持的对象类型。如果是Vector，
 * 后面字符串是该Vector容器中对象类型的附加信息编码；如果是MAP，后面字符串的前两个字符的数值等于
 * Key的类型信息编码字符串长度(00, 99]，然后再是Key的类型信息编码和Value的类型信息编码。
 *
 * Vector<string>                    ->> VONSString 
 * MAP<string, string>               ->> M09ONSStringONSString
 * MAP<string, Vector<string>>       ->> M09ONSStringVONSString
 * MAP<MttTarsObject1, MttTarsObject2> ->> M14OMttTarsObject1OMttTarsObject2
 * Vector<byte>                      ->> 映射到NSData类型，不需要附加信息编码
 * Vector<int>                       ->> 因NSArray中必须是对象，按NSArray<NSNumber>处理
 * Map<int, Vector<byte>>            ->> M09ONSNumberONSData
 *
 * 框架所支持的非容器对象类型包括：NSData，NSNumber，NSString，TarsObject及其派生对象
 * 不支持包含下划线的属性名，不支持类名中包含下划线的TarsObject派生类，不支持ext长度超过99
 *
 */
#define TarsV2_PROPERTY_NAME_PREFIX          Tars_
#define TarsV2_PROPERTY_NAME_PREFIX_U        Tars_
#define TarsV2_PROPERTY_NAME_PREFIX_STR      @"Tars_"
#define TarsV2_PROPERTY_LVNAME_PREFIX        Tarsv2_p_
#define TarsV2_PROPERTY_LVNAME_PREFIX_STR    @"Tarsv2_p_"

#define TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER__(prefixL, prefixU, name) getter = prefixL##name, setter = set##prefixU##name:
#define TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER_(prefixL, prefixU, name) TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER__(prefixL, prefixU, name)
#define TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER(name) TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER_(TarsV2_PROPERTY_NAME_PREFIX, TarsV2_PROPERTY_NAME_PREFIX_U, name)
#define TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER_V2(gname, sname) getter = gname, setter = sname

#define TarsV2_PROPERTY_NAME_NM__(prefix, flag, tag, name)       prefix##tag##_##flag##_##name
#define TarsV2_PROPERTY_NAME_EX__(prefix, flag, tag, name, ext)  prefix##tag##_##flag##_##name##__x_##ext
#define TarsV2_PROPERTY_NAME_NM_(prefix, flag, tag, name)        TarsV2_PROPERTY_NAME_NM__(prefix, flag, tag, name)
#define TarsV2_PROPERTY_NAME_EX_(prefix, flag, tag, name, ext)   TarsV2_PROPERTY_NAME_EX__(prefix, flag, tag, name, ext)
#define TarsV2_PROPERTY_NAME_NM(flag, tag, name)                 TarsV2_PROPERTY_NAME_NM_(TarsV2_PROPERTY_LVNAME_PREFIX, flag, tag, name)
#define TarsV2_PROPERTY_NAME_EX(flag, tag, name, ext)            TarsV2_PROPERTY_NAME_EX_(TarsV2_PROPERTY_LVNAME_PREFIX, flag, tag, name, ext)

#define JV2_PROP_GS(name)                   TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER(name)
#if TarsV2_DEFAULT_GETTER_AND_SETTER
    #define JV2_PROP_GS_V2(gname, sname)    TarsV2_PROPERTY_ATTR_GETTER_AND_SETTER_V2(gname, sname)
    #define JV2_PROP_(name)                 self.name
    #define JV2_PROP(name)                  JV2_PROP_(name)
#else /*TarsV2_DEFAULT_GETTER_AND_SETTER*/
    #define JV2_PROP_GS_V2(gname, sname)    JV2_PROP_GS(gname)
    #define JV2_PROP(name)                  self.Tars_##name
#endif /*TarsV2_DEFAULT_GETTER_AND_SETTER*/
#define JV2_PROP_NM(flag, tag, name)        TarsV2_PROPERTY_NAME_NM(flag, tag, name)
#define JV2_PROP_EX(flag, tag, name, ext)   TarsV2_PROPERTY_NAME_EX(flag, tag, name, ext)
#define JV2_PROP_NFX_STR                    TarsV2_PROPERTY_NAME_PREFIX_STR
#define JV2_PROP_LFX_STR                    TarsV2_PROPERTY_LVNAME_PREFIX_STR

@interface TarsObjectV2 : TarsObject

@end
