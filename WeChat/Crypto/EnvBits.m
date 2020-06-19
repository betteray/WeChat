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

typedef char _BYTE;

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
    v0 = 0;// sub_16918();
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
    v77 = dword_1D408;
    v78 = 4;
    v79 = (tv.tv_usec & 0xE) | 1;
    do
    {
        if ( !(v78 & 3) )
            v79 = (3877 * v79 + 5) & 0xF;
        v77 ^= ((v79 >> (v78 & 3)) & 1) << v78;
        ++v78;
    }
    while ( v78 != 24 );
    dword_1D408 = v77 | (tv.tv_usec & 0xE) | 1;
    return dword_1D408;
}

@end
