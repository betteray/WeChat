//
//  Constants.h
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#ifndef Constants
#define Constants

#define PROTOCOL_FOR_IOS 0
#define PROTOCOL_FOR_ANDROID !PROTOCOL_FOR_IOS

#define LOGIN_RSA_VER_172 174
#define LOGIN_RSA_VER172_KEY_E @"10002"
#define LOGIN_RSA_VER172_KEY_N @"D153E8A2B314D2110250A0A550DDACDC"\
                                "D77F5801F3D1CC21CB1B477E4F2DE869"\
                                "7D40F10265D066BE8200876BB7135EDC"\
                                "74CDBC7C4428064E0CDCBE1B6B92D93C"\
                                "EAD69EC27126DEBDE564AAE1519ACA83"\
                                "6AA70487346C85931273E3AA9D24A721"\
                                "D0B854A7FCB9DED49EE03A44C189124F"\
                                "BEB8B17BB1DBE47A534637777D33EEC8"\
                                "8802CD56D0C7683A796027474FEBF237"\
                                "FA5BF85C044ADC63885A70388CD3696D"\
                                "1F2E466EB6666EC8EFE1F91BC9353F8F"\
                                "0EAC67CC7B3281F819A17501E15D0329"\
                                "1A2A189F6A35592130DE2FE5ED8E3ED5"\
                                "9F65C488391E2D9557748D4065D00CBE"\
                                "A74EB8CA19867C65B3E57237BAA8BF0C"\
                                "0F79EBFC72E78AC29621C8AD61A2B79B"

#define I666 0x16060620
#define I667 0x16060720
#define I671 0x16070124
#define I672 0x16070315
#define I674 369558575
#define I700 385876008

#define I70239 @"7.0.2.39" //ok
#define I70367 @"7.0.3.67" //ok
#define I70440 @"7.0.4.40"

#define IVERSION I70440 //modify this to change version num

#define A666 637929010
#define A700 654311476
#define A703  0x27000334
#define A704  0x27000437
#define A705  0x27000530
#define A706  0x27000634

#define AVERSION A706

#if PROTOCOL_FOR_IOS
    #define CLIENT_VERSION [CUtility numberVersionOf:IVERSION]
#elif PROTOCOL_FOR_ANDROID
    #define CLIENT_VERSION AVERSION
#endif

#define USE_MMTLS 1

#endif /* Header_h */
