//
//  Constants.h
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#ifndef Constants
#define Constants

#define PROTOCOL_FOR_IOS 1
#define PROTOCOL_FOR_ANDROID !PROTOCOL_FOR_IOS

#define LOGIN_RSA_VER_172 174
#define LOGIN_RSA_VER172_KEY_E @"10001"
#define LOGIN_RSA_VER172_KEY_N @"D153E8A2B314D2110250A0A550DDACDCD77F5801F3D1CC21CB1B477E4F2DE8697D40F10265D066BE8200876BB7135EDC74CDBC7C4428064E0CDCBE1B6B92D93CEAD69EC27126DEBDE564AAE1519ACA836AA70487346C85931273E3AA9D24A721D0B854A7FCB9DED49EE03A44C189124FBEB8B17BB1DBE47A534637777D33EEC88802CD56D0C7683A796027474FEBF237FA5BF85C044ADC63885A70388CD3696D1F2E466EB6666EC8EFE1F91BC9353F8F0EAC67CC7B3281F819A17501E15D03291A2A189F6A35592130DE2FE5ED8E3ED59F65C488391E2D9557748D4065D00CBEA74EB8CA19867C65B3E57237BAA8BF0C0F79EBFC72E78AC29621C8AD61A2B79B"

#if PROTOCOL_FOR_IOS
    //666 = 369493536 = 0x16060620
    //667 = 369493792 = 0x16060720
    //671 = 369557796 = 0x16070124
    //672 = 369558293 = 0x16070315
    //674 = 369558574 = 0x1607042e
    #define CLIENT_VERSION 369558575    //ios 674 update
#elif PROTOCOL_FOR_ANDROID
    #define CLIENT_VERSION 637929010    //android 666 = 637929010
#endif

#define USE_MMTLS 1

#endif /* Header_h */
