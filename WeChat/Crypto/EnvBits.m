//
//  EnvBits.m
//  WeChat
//
//  Created by ray on 2020/6/19.
//  Copyright © 2020 ray. All rights reserved.
//

#import "EnvBits.h"
#include <sys/time.h>
#include <stdint.h>

@implementation EnvBits

+ (int)GetEnvBits
{
    int v0; // r0
    unsigned int v1; // r1
    int v2; // r1
    
    int v77; // r1
    signed int v78; // r2
    unsigned int v79; // r3
    struct timeval tv = {0}; // [sp+10h] [bp-110h]
    
    int dword_1D408 = 0;
    v0 = 10;// sub_16918();
    if ( v0 != 10 && v0 )
    {
        v2 = dword_1D408 | 0x4000000;
    }
    else
    {
        v1 = dword_1D408 & 0xFBFFFFFF;
        dword_1D408 &= 0xFBFFFFFF;
        if ( v0 )
            goto LABEL_7;
        v2 = v1 | 0x8000000;
    }
    dword_1D408 = v2;
    
LABEL_7:
    
    gettimeofday(&tv, 0);
    
    v77 = dword_1D408; //0初始值（标识位），可以通过下面方法穷举反推标志位。
    v78 = 4;
    v79 = (tv.tv_usec & 0xE) | 1; // 0xe = 1110 , v79有8种可能： 0001，0011， 0101， 0111，。。。。 1-15中的奇数
    do
    {
        if ( !(v78 & 3) ) // 1100 都会进去 4， 12， 28（到不了）
            v79 = (3877 * v79 + 5) & 0xF;
        v77 ^= ((v79 >> (v78 & 3)) & 1) << v78;  // v78 & 3 ，4，12时为0就不需要移位。
        ++v78;
    }
    while ( v78 != 24 );
    // v77
    dword_1D408 = v77 | (tv.tv_usec & 0xE) | 1;
    return dword_1D408;
}

// 通过从0开始枚举反推中间值。
//for (int i=0; i<0xffffffff; i++) {
//    BOOL match = [EnvBits GetEnvBits2:i result:141395873];
//    if (match) {
//        LogVerbose(@"%d", i);
//    }
//}

+ (BOOL)GetEnvBits2:(int)guess result:(int)res
{
    int v0; // r0
    unsigned int v1; // r1
    int v2; // r1
    
    int v77; // r1
    signed int v78; // r2
    unsigned int v79; // r3
    struct timeval tv = {0}; // [sp+10h] [bp-110h]
    
    int dword_1D408 = 0;
    v0 = 10;// sub_16918();
    if ( v0 != 10 && v0 )
    {
        v2 = dword_1D408 | 0x4000000;
    }
    else
    {
        v1 = dword_1D408 & 0xFBFFFFFF;
        dword_1D408 &= 0xFBFFFFFF;
        if ( v0 )
            goto LABEL_7;
        v2 = v1 | 0x8000000;
    }
    dword_1D408 = v2;
    
LABEL_7:
    
    gettimeofday(&tv, 0);
    tv.tv_usec = res & 0xE; // 根据上面反推，就结果中的这几位（1110=E）重要。
    
    v77 = guess; //0
    v78 = 4;
    v79 = (tv.tv_usec & 0xE) | 1; // 0xe = 1110 , v79有8种可能： 0001，0011， 0101， 0111，。。。。 1-15中的奇数
    do
    {
        if ( !(v78 & 3) ) // 1100 都会进去 4， 12， 28（到不了）
            v79 = (3877 * v79 + 5) & 0xF;
        v77 ^= ((v79 >> (v78 & 3)) & 1) << v78;  // v78 & 3 ，4，12时为0就不需要移位。
        ++v78;
    }
    while ( v78 != 24 );
    // v77
    dword_1D408 = v77 | (tv.tv_usec & 0xE) | 1;

    return dword_1D408 == res;
}


// v78 4 -- 24,
@end
