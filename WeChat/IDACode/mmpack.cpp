//
//  mmpack.c
//  Pack
//
//  Created by ray on 2019/1/27.
//  Copyright © 2019 ray. All rights reserved.
//

#include "mmpack.h"
#include <zlib.h>
#include <string.h>
#include <stdio.h>

//////

__int64 sub_103513FBC(__int64 result)
{
    *(_QWORD *)result = 0LL;
    *(_QWORD *)(result + 8) = 0LL;
    *(_DWORD *)(result + 16) = 0;
    return result;
}

/////

__int64 sub_103513FF8(__int64 a1, signed int a2)
{
    __int64 v2; // x19
    signed int v3; // w23
    size_t v4; // x21
    size_t v5; // x24
    void *v6; // x22
    void *v7; // x20
    
    v2 = a1;
    if ( a2 <= 1 )
        v3 = 1;
    else
        v3 = a2;
    v4 = *(signed int *)(a1 + 8);
    v5 = v4 + v3;
    if ( (signed int)v5 > *(_DWORD *)(a1 + 16) )
    {
        v6 = *(void **)a1;
        if ( *(_QWORD *)a1 )
        {
            v7 = (void *)operator new[](v5 + 1);
            *(_DWORD *)(v2 + 16) = v5;
            memcpy(v7, v6, v4);
            operator delete[](v6);
            v3 = *(_DWORD *)(v2 + 16);
        }
        else
        {
            *(_DWORD *)(a1 + 8) = 0;
            *(_DWORD *)(a1 + 16) = v3;
            v7 = (void *)operator new[]((unsigned int)(v3 + 1));
        }
        *(_QWORD *)v2 = (uint64)v7;
        *((_BYTE *)v7 + v3) = 0;
    }
    return 0LL;
}

__int64 __fastcall sub_1035141AC(__int64 a1)
{
    return *(_QWORD *)a1;
}

__int64 sub_103514110(__int64 result, int a2)
{
    *(_DWORD *)(result + 8) = a2;
    return result;
}

void sub_103513FC8(void **a1)
{
    void **v1; // x19
    void *v2; // x0
    
    v1 = a1;
    v2 = *a1;
    if ( v2 )
//        operator delete[](v2);
    *v1 = 0LL;
    v1[1] = 0LL;
    *((_DWORD *)v1 + 4) = 0;
}

void sub_1035141D0(void **a1, void **a2)
{
    void **v2; // x19
    void **v3; // x20
    void *v4; // x0
    
    v2 = a2;
    v3 = a1;
    if ( a2 != a1 )
    {
        v4 = *a1;
        if ( *v3 )
            operator delete[](v4);
        *v3 = 0LL;
        v3[1] = 0LL;
        *((_DWORD *)v3 + 4) = 0;
        if ( v2 )
        {
            *v3 = *v2;
            v3[1] = v2[1];
            *((_DWORD *)v3 + 4) = *((_DWORD *)v2 + 4);
            *v2 = 0LL;
            v2[1] = 0LL;
            *((_DWORD *)v2 + 4) = 0;
        }
    }
}

void ** sub_103514094(void **a1)
{
    void **v1; // x19
    void *v2; // x0
    
    v1 = a1;
    v2 = *a1;
    if ( v2 )
        operator delete[](v2);
    *v1 = 0LL;
    v1[1] = 0LL;
    *((_DWORD *)v1 + 4) = 0;
    return v1;
}


__int64 sub_103514118(__int64 a1, const void *a2, __int64 a3)
{
    __int64 v3; // x19
    const void *v4; // x21
    __int64 v5; // x20
    void *v6; // x0
    
    v3 = a3;
    v4 = a2;
    v5 = a1;
    if ( (unsigned int)sub_103513FF8(a1, a3) )
        return 0LL;
    v6 = (void *)(*(_QWORD *)v5 + *(signed int *)(v5 + 8));
    if ( !v6 )
        return 0LL;
    memcpy(v6, v4, (signed int)v3);
    *(_DWORD *)(v5 + 8) += v3;
    return v3;
}

signed __int64 sub_1035146A4(const Bytef *a1, uLong a2, __int64 a3, unsigned __int16 *a4, _WORD *a5)
{
    _WORD *v5; // x22
    unsigned __int16 *v6; // x23
    __int64 v7; // x19
    uLongf v8; // x21
    const Bytef *v9; // x20
    signed __int64 result; // x0
    int v11; // w8
    uLong v12; // x0
    signed int v13; // w24
    Bytef *v14; // x0
    int v15; // w24
    __int64 v16; // [xsp+0h] [xbp-50h]
    uLongf destLen; // [xsp+18h] [xbp-38h]
    
    v5 = a5;
    v6 = a4;
    v7 = a3;
    v8 = a2;
    v9 = a1;
    result = 2LL;
    if ( v9 && a3 )
    {
        if ( *a5 == 1001 )
        {
            v11 = *a4;
            if ( (unsigned int)(v11 - 1) > 1 )
            {
                result = 7LL;
            }
            else
            {
                if ( v11 == 1 )
                {
                    v12 = compressBound(a2);
                    v13 = v12;
                    destLen = v12;
                    sub_103513FBC((__int64)&v16);
                    sub_103513FF8((__int64)&v16, v13);
                    v14 = (Byte *)sub_1035141AC((__int64)&v16);
                    v15 = compress(v14, &destLen, v9, v8);
                    sub_103514110((__int64)&v16, (unsigned int)destLen);
                    if ( !v15 && destLen < v8 )
                    {
                        sub_103513FC8((void **)v7);
                        sub_1035141D0((void **)v7, (void **)&v16);
                        sub_103514094((void **)&v16);
                        return 0LL;
                    }
                    sub_103514094((void **)&v16);
                }
                *v6 = 2;
                *v5 = 1001;
                sub_103513FC8((void **)v7);
                sub_103513FF8((__int64)v7, v8);
                sub_103514118(v7, v9, v8);
                result = 8LL;
            }
        }
        else
        {
            result = 4LL;
        }
    }
    return result;
}

_QWORD * sub_103517C9C(_QWORD *a1)
{
    _QWORD *v1; // x19
    _QWORD *v2; // x0
    
    v1 = a1;
    v2 = (_QWORD *)operator new(0x18uLL);
    *v1 = (_QWORD)v2;
    *v2 = 0LL;
    v2[1] = 0LL;
    v2[2] = 0LL;
    return v1;
}

__int64 sub_103516854(__int64 a1, int a2)
{
    int v2; // w20
    __int64 v3; // x19
    
    v2 = a2;
    v3 = a1;
    sub_103517C9C((_QWORD *)(a1 + 56));
    if ( v2 == 2 )
    {
//        *(_OWORD *)(v3 + 36) = 0u;    //_OWORD 16 bytes
        *(_DWORD *)(v3 + 52) = 0;
//        *(_OWORD *)(v3 + 20) = 0u;
//        *(_OWORD *)(v3 + 4) = 0u;
        *(_BYTE *)(v3 + 50) = -1;
    }
    *(_DWORD *)v3 = v2;
    return v3;
}

__int64 sub_1035169CC(__int64 result, char a2)
{
    *(_BYTE *)(result + 45) = a2;
    return result;
}

__int64 sub_1035169D4(__int64 result, int a2)
{
    *(_DWORD *)(result + 46) = a2;
    return result;
}

__int64 sub_1035168E0(__int64 result, int a2)
{
    *(_DWORD *)(result + 8) = a2;
    return result;
}

__int64 sub_1035168F8(__int64 result, int a2)
{
    *(_DWORD *)(result + 12) = a2;
    return result;
}

__int64 sub_1035168F0(__int64 result, __int16 a2)
{
    *(_WORD *)(result + 31) = a2;
    return result;
}

__int64 sub_1035169BC(__int64 result, __int16 a2)
{
    *(_WORD *)(result + 41) = a2;
    return result;
}

char * sub_103516980(char *result, const void *a2, size_t a3)
{
    char v3; // w19
    char *v4; // x20
    
    v3 = a3;
    v4 = result;
    if ( a2 )
    {
        if ( a3 <= 0xF )
        {
            result = (char *)memcpy(result + 16, a2, a3);
            v4[7] = v3;
        }
    }
    return result;
}

__int64 sub_1035169C4(__int64 result, __int16 a2)
{
    *(_WORD *)(result + 43) = a2;
    return result;
}

__int64 sub_10351691C(__int64 result, int a2)
{
    *(_DWORD *)(result + 33) = a2;
    return result;
}

__int64 sub_10351418C(__int64 a1)
{
    return *(unsigned int *)(a1 + 8);
}

__int64 sub_103516924(__int64 result, int a2)
{
    *(_DWORD *)(result + 37) = a2;
    return result;
}

__int64 sub_103516934(__int64 result, char a2)
{
    *(_BYTE *)(result + 5) = a2;
    return result;
}

__int64 sub_10351690C(__int64 result, char a2)
{
    *(_BYTE *)(result + 6) = a2;
    return result;
}

__int64 sub_1035169E4(__int64 result, char a2)
{
    *(_BYTE *)(result + 50) = a2;
    return result;
}

__int64 sub_1035169FC(__int64 result, char a2)
{
    *(_BYTE *)(result + 55) = a2;
    return result;
}

__int64 sub_10351419C(__int64 a1)
{
    return *(_QWORD *)a1 + *(signed int *)(a1 + 12);
}

__int64 sub_1035169F4(__int64 result, int a2)
{
    *(_DWORD *)(result + 51) = a2;
    return result;
}

signed __int64 sub_1035168D8(__int64 a1)
{
    return a1 + 56;
}

__int64 sub_103517D50(__int64 *a1, signed int a2)
{
    __int64 *v2; // x19
    signed int v3; // w8
    __int64 v4; // x21
    signed __int64 v5; // x9
    signed int *v6; // x22
    void *v7; // x20
    void *v8; // x0
    __int64 v9; // x8
    
    v2 = a1;
    if ( a2 <= 1 )
        v3 = 1;
    else
        v3 = a2;
    v4 = *a1;
    v5 = *(signed int *)(*a1 + 12) + (signed __int64)v3;
    v6 = (signed int *)(*a1 + 16);
    if ( (signed int)v5 > *v6 )
    {
        if ( *(_QWORD *)v4 )
        {
            *(_DWORD *)(v4 + 16) = v5;
            v7 = (void *)operator new[](v5 + 1);
            memcpy(v7, *(const void **)v4, *(signed int *)(v4 + 12));
            v8 = *(void **)v4;
            if ( *(_BYTE *)(v4 + 20) )
            {
//                free(v8);
            }
            else if ( v8 )
            {
                operator delete[](v8);
            }
            v9 = *v2;
            *(_QWORD *)v9 = (_QWORD) v7;
            *(_BYTE *)(v9 + 20) = 0;
            v6 = (signed int *)(v9 + 16);
        }
        else
        {
            *(_DWORD *)(v4 + 12) = 0;
            *(_DWORD *)(v4 + 16) = v3;
            v7 = (void *)operator new[]((unsigned int)(v3 + 1));
            *(_QWORD *)v4 = (_QWORD) v7;
        }
        *((_BYTE *)v7 + *v6) = 0;
    }
    return 0LL;
}

__int64 __fastcall sub_103517E0C(__int64 a1, const void *a2, __int64 a3)
{
    __int64 v3; // x19
    const void *v4; // x20
    __int64 v5; // x21
    
    v3 = a3;
    v4 = a2;
    v5 = a1;
    sub_103517D50((__int64 *)a1, a3);
    memcpy((void *)(**(_QWORD **)v5 + *(signed int *)(*(_QWORD *)v5 + 12LL)), v4, (signed int)v3);
    *(_DWORD *)(*(_QWORD *)v5 + 12LL) += v3;
    return v3;
}

signed __int64 sub_10351B854(__int64 a1, unsigned int *a2, unsigned int a3, unsigned __int64 a4)
{
    signed int v4; // w8
    unsigned __int64 v5; // x9
    signed int v6; // w9
    unsigned int v7; // w8
    char v9; // w9
    
    v4 = -1;
    v5 = a4;
    do
    {
        v5 >>= 7;
        ++v4;
    }
    while ( v5 );
    if ( v4 )
        v6 = v4;
    else
        v6 = 1;
    v7 = *a2;
    if ( *a2 + v6 > a3 )
        return 4294967294LL;
    while ( v7 < a3 )
    {
        v9 = a4 | 0x80;
        if ( a4 <= 0x7F )
            v9 = a4;
        *a2 = v7 + 1;
        *(_BYTE *)(a1 + v7) = v9;
        a4 >>= 7;
        if ( !a4 )
            break;
        v7 = *a2;
    }
    return 0LL;
}

u_int32_t
bswap32(u_int32_t x)
{
    return    ((x << 24) & 0xff000000 ) |
    ((x <<  8) & 0x00ff0000 ) |
    ((x >>  8) & 0x0000ff00 ) |
    ((x >> 24) & 0x000000ff );
}

signed __int64 sub_10351B540(__int64 a1, _WORD *a2, unsigned int *a3, __int64 a4)
{
    __int64 v4; // x22
    unsigned int *v5; // x20
    _WORD *v6; // x19
    __int64 v7; // x21
    signed __int64 result; // x0
    __int64 v9; // x8
    __int64 v10; // x8
    __int64 v11; // x8
    unsigned int v12; // w8
    int v13; // w23
    unsigned int v14; // w8
    __int64 v15; // x8
    __int64 v16; // x8
    unsigned int v17; // w9
    
    v4 = a4;
    v5 = a3;
    v6 = a2;
    v7 = a1;
    result = 0xFFFFFFFFLL;
    if ( v7 && a2 && a3 )
    {
        if ( *(unsigned __int8 *)(v7 + 1) > 3u || *(unsigned __int8 *)(v7 + 2) > 0xFu || *(unsigned __int8 *)(v7 + 3) > 0xFu )
            return 4294967293LL;
        v9 = *a3;
        if ( *(_BYTE *)(v7 + 41) )
        {
            if ( (signed int)v9 + 1 > (unsigned int)a4 )
                return 4294967205LL;
            *((_BYTE *)a2 + v9) = -65;
            LODWORD(v9) = *a3 + 1;
            *a3 = v9;
        }
        if ( (signed int)v9 + 2 > (unsigned int)a4 )
            return 4294967194LL;
        *(_WORD *)((char *)a2 + (unsigned int)v9) = ((unsigned __int8)(*(_BYTE *)(v7 + 1) & 3 | 4 * (*(_BYTE *)v7 & 0x3F)) | (unsigned __int16)((*(_BYTE *)(v7 + 3) & 0xF) << 8)) & 0xFFF | (*(unsigned __int8 *)(v7 + 2) << 12);
        v10 = *a3 + 2;
        *a3 = v10;
        if ( v10 + 4 > (unsigned __int64)(unsigned int)a4 )
            return 4294967191LL;
        *(_DWORD *)((char *)a2 + v10) = bswap32(*(_DWORD *)(v7 + 4));
        v11 = *a3 + 4;
        *a3 = v11;
        if ( v11 + 4 > (unsigned __int64)(unsigned int)a4 )
            return 4294967190LL;
        *(_DWORD *)((char *)a2 + v11) = bswap32(*(_DWORD *)(v7 + 8));
        v12 = *a3 + 4;
        *a3 = v12;
        v13 = *(unsigned __int8 *)(v7 + 3);
        if ( v12 + v13 > (unsigned int)a4 )
            return 4294967186LL;
        memcpy((char *)a2 + v12, (const void *)(v7 + 12), *(unsigned __int8 *)(v7 + 3));
        *v5 += v13;
        if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned __int16 *)(v7 + 27)) )
            return 4294967185LL;
        if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned int *)(v7 + 29)) )
            return 4294967184LL;
        if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned int *)(v7 + 33)) )
            return 4294967183LL;
        if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned __int16 *)(v7 + 37)) )
            return 4294967182LL;
        if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned __int16 *)(v7 + 39)) )
            return 4294967181LL;
        if ( *(_BYTE *)(v7 + 41) )
        {
            if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned int *)(v7 + 42)) )
                return 4294967176LL;
            v15 = *v5;
            if ( (signed int)v15 + 1 > (unsigned int)v4 )
                return 4294967175LL;
            *((_BYTE *)v6 + v15) = *(_BYTE *)(v7 + 46);
            ++*v5;
            if ( (unsigned int)sub_10351B854((__int64) v6, v5, v4, *(unsigned int *)(v7 + 47)) )
                return 4294967174LL;
            v16 = *v5;
            if ( (signed int)v16 + 1 > (unsigned int)v4 )
                return 4294967173LL;
            *((_BYTE *)v6 + v16) = *(_BYTE *)(v7 + 51);
            v17 = *v5;
            v14 = *v5 + 1;
            *v5 = v14;
            if ( *(_BYTE *)(v7 + 41) )
            {
                if ( v17 <= 0x38 )
                {
                    result = 0LL;
                    *(_WORD *)((char *)v6 + 1) = *(_WORD *)((char *)v6 + 1) & 0xFF03 | 4 * (v14 & 0x3F);
                    return result;
                }
                return 0xFFFFFFFFLL;
            }
        }
        else
        {
            v14 = *v5;
        }
        if ( v14 <= 0x2E )
        {
            result = 0LL;
            *v6 = *v6 & 0xFF03 | 4 * (v14 & 0x3F);
            return result;
        }
        return 0xFFFFFFFFLL;
    }
    return result;
}

__int64 sub_103517E88(__int64 a1)
{
    return *(unsigned int *)(*(_QWORD *)a1 + 12LL);
}

__int64 sub_103517E94(__int64 a1)
{
    return **(_QWORD **)a1;
}

__int64 sub_10351BDC0(__int64 a1, __int64 a2, __int64 a3)
{
    __int64 v3; // x19
    __int64 v4; // x20
    __int64 result; // x0
    signed __int64 v6; // x21
    unsigned int v7; // w22
    int v8; // w22
    const void *v9; // x23
    __int64 v10; // x0
    __int64 v11; // [xsp+8h] [xbp-458h]
    unsigned int v12; // [xsp+14h] [xbp-44Ch]
    char v13; // [xsp+18h] [xbp-448h]
    
    v3 = a3;
    v4 = a2;
    v12 = 0;
    result = sub_10351B540((__int64) a1, (_WORD *) &v13, (unsigned int *) &v12, 1024LL);
    v6 = result;
    if ( !(_DWORD)result )
    {
        v7 = v12;
        result = sub_103517E0C(v3, &v13, v12);
        v6 = 4294967294LL;
        if ( v7 == (_DWORD)result )
        {
            v8 = sub_103517E88(v4);
            v9 = (const void *)sub_103517E94(v4);
            v10 = sub_103517E88(v4);
            result = sub_103517E0C(v3, v9, v10);
            if ( v8 == (_DWORD)result )
                v6 = 0LL;
            else
                v6 = 4294967294LL;
        }
    }
    return result;
}


__int64 sub_103516A04(_DWORD *a1, __int64 a2)
{
    __int64 result; // x0
    
    if ( a2 && *a1 == 2 )
        result = sub_10351BDC0((__int64) (a1 + 1), (__int64) (a1 + 14), (__int64) a2);
    else
        result = 0xFFFFFFFFLL;
    return result;
}

__int64 sub_103517EA0(__int64 **a1, _DWORD *a2)
{
    __int64 *v2; // x8
    __int64 result; // x0
    
    v2 = *a1;
    result = **a1;
    if ( a2 )
        *a2 = *((_DWORD *)v2 + 3);
    *v2 = 0LL;
    v2[1] = 0LL;
    v2[2] = 0LL;
    return result;
}

void sub_103517D04(void ***a1)
{
    void ***v1; // x19
    void **v2; // x8
    void *v3; // x0
    void **v4; // x8
    
    v1 = a1;
    v2 = *a1;
    v3 = **a1;
    if ( v3 )
    {
        if ( *((_BYTE *)v2 + 20) )
            ;
//            free(v3);
        else
            operator delete[](v3);
    }
    v4 = *v1;
    *v4 = 0LL;
    v4[1] = 0LL;
    v4[2] = 0LL;
}

void ** sub_103517CD0(void **a1)
{
    void **v1; // x19
    
    v1 = a1;
    sub_103517D04((void ***)a1);
    if ( *v1 )
        operator delete(*v1);
    *v1 = 0LL;
    return v1;
}

__int64 sub_103517D4C(__int64 a1)
{
    return (__int64)sub_103517CD0((void **)a1);
}

__int64 sub_1035168A8(__int64 a1)
{
    __int64 v1; // x19
    
    v1 = a1;
//    sub_103517D4C(a1 + 56);
    return v1;
}

__int64 EncodePack(AutoBuffer *a1, __int64 a2, __int64 a3, AutoBuffer *a4, const char *a5, unsigned int a6, __int64 a7, const char *a8, unsigned int a9, unsigned int a10, unsigned __int8 a11)
{
    const char *v11; // x26
    __int64 v12; // x23
    unsigned int v13; // w27
    const char *v14; // x28
    AutoBuffer *v15; // x21
    __int64 v16; // x24
    __int64 v17; // x20
    __int64 v18; // x8
    __int64 v19; // x25
    __int64 v20; // x0
    const char *v21; // x1
    const char *v22; // x1
    void *v23; // x19
    __int64 v24; // x0
    unsigned __int8 v25; // w8
    __int64 v26; // x20
    __int64 v27; // x0
    __int64 v28; // x0
    __int64 v29; // x19
    __int64 v30; // x20
    __int64 v31; // x21
    __int64 v32; // x0
    void *v33; // x0
    void *v34; // x19
    void *v35; // x0
    void *v36; // x0
    void *v37; // x20
    void *v38; // x21
    __int64 v39; // x0
    __int64 v40; // x19
    __int64 v41; // x0
    signed __int64 v42; // x19
    __int64 v43; // x20
    __int64 v44; // ST10_8
    __int64 v45; // ST08_8
    __int64 result; // x0
    void *v47; // x0
    __int64 v48; // [xsp+10h] [xbp-130h]
    AutoBuffer *v49; // [xsp+58h] [xbp-E8h]
    unsigned __int64 v50; // [xsp+6Ch] [xbp-D4h]
    unsigned int v51; // [xsp+7Ch] [xbp-C4h]
    void *v52; // [xsp+80h] [xbp-C0h]
    __int16 v53; // [xsp+8Ch] [xbp-B4h]
    __int16 v54; // [xsp+8Eh] [xbp-B2h]
    char v55; // [xsp+90h] [xbp-B0h]
    char v56; // [xsp+A8h] [xbp-98h]
    __int64 v57; // [xsp+E8h] [xbp-58h]
    
    v11 = a8;
    v12 = a7;
    v13 = a6;
    v14 = a5;
    v15 = a4;
    v16 = a3;
    v17 = a2;
    v49 = a1;
//    v18 = (unsigned __int8)byte_104CA91A7;
//    if ( byte_104CA91A7 < 0 )
//        v18 = qword_104CA9198;
//    if ( v18 )
//        v19 = Comm::GenSignature(a7, &qword_104CA9190, a2, a3);
//    else
//        v19 = 0LL;
    sub_103513FBC((__int64) &v55);
    v54 = 1;
    v53 = 1001;
    //signed __int64 sub_1035146A4(const Bytef *a1, uLong a2, __int64 a3, unsigned __int16 *a4, _WORD *a5)
    v20 = sub_1035146A4((const Bytef *)v17, (uLong) v16, (__int64)&v55, (unsigned __int16 *)&v54, (_WORD *)&v53);
    if ( ((unsigned int)v20 | 8) != 8 )
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         104LL,
//                                                                         "EncodePack",
//                                                                         CFSTR("compress pack error! ret=%d, inLen=%u"),
//                                                                         v20,
//                                                                         v16);
    sub_103516854((__int64) &v56, 2LL);
    sub_1035169CC((__int64) &v56, 1LL);
    sub_1035169D4((__int64) &v56, v19);
    sub_1035168E0((__int64) &v56, a10);
    sub_1035168F8((__int64) &v56, v12);
    sub_1035168F0((__int64) &v56, (unsigned __int16)a9);
    sub_1035169BC((__int64) &v56, 0LL);
    if ( v14 )
        v21 = v14;
    else
        v21 = "";
    sub_103516980(&v56, v21, v13);
    if ( v11 )
        v22 = v11;
    else
        v22 = "";
//    nullsub_491(&v56, v22, 16LL);
    v23 = 0; //+[DeviceUtility HeadDeviceType](&OBJC_CLASS___DeviceUtility, "HeadDeviceType");
    sub_1035169C4((__int64) &v56, 0/*(__int16)v23*/);
    sub_10351691C((__int64) &v56, v16);
    v24 = sub_10351418C((__int64) &v55);
    sub_103516924((__int64) &v56, v24);
    sub_103516934((__int64) &v56, (unsigned int)v54);
//    nullsub_492((__int64) &v56, (unsigned int)v53);
    sub_10351690C((__int64) &v56, 5LL);
//    if ( byte_104C8A0A8 )
//        v25 = 8 * (byte_104C8A0A9 == 0);
//    else
//        v25 = 9;
    v26 = v25;
    sub_1035169E4((__int64) &v56, v26);
    sub_1035169FC((__int64) &v56, a11);
    v27 = sub_10351418C((__int64) &v55);
//    +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                     &OBJC_CLASS___iConsole,
//                                                                     "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                     2LL,
//                                                                     0LL,
//                                                                     0LL,
//                                                                     "mmpack.mm",
//                                                                     137LL,
//                                                                     "EncodePack",
//                                                                     CFSTR("aes pack cgi=%d, uin=%u, checksum=%u, devideType=%u, compressLen=%u, compressedLen=%u, compressAlgo=%u, compressVer=%u, flag=%u"),
//                                                                     a9,
//                                                                     v12,
//                                                                     v19,
//                                                                     v23,
//                                                                     v16,
//                                                                     v27,
//                                                                     v54,
//                                                                     v53,
//                                                                     v26);
//    if ( !AutoBuffer::Length(v15) )
//    {
//        v28 = AutoBuffer::Length(v15);
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         143LL,
//                                                                         "EncodePack",
//                                                                         CFSTR("_key.Length() <= 0, KeyLength:%zd"),
//                                                                         v28);
//    }
//    if ( !AutoBuffer::Length(v15) || (signed int)sub_10351418C(&v55) <= 0 )
//    {
//        v43 = AutoBuffer::Ptr(v15, 0LL);
//        v44 = sub_10351419C(&v55);
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         149LL,
//                                                                         "EncodePack",
//                                                                         CFSTR("key or input data empty(EncodePack)! keyPtr=%p, inputDataPtr=%p"),
//                                                                         v43,
//                                                                         v44);
//    LABEL_28:
//        v42 = 0LL;
//        goto LABEL_29;
//    }
    v52 = 0LL;
    v51 = 0;
//    v29 = AutoBuffer::Ptr(v15, 0LL);
//    v30 = AutoBuffer::Length(v15);
    v29 = (long long)v15->Ptr();
    v30 = v15->Length();
    v31 = sub_10351419C((__int64) &v55);
    v32 = sub_10351418C((__int64) &v55);
//    if ( (unsigned int)aes_cbc_encrypt(v29, v30, v31, v32, &v52, &v51) || !v52 || !v51 )
    {
//        v45 = sub_10351418C(&v55);
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         167LL,
//                                                                         "EncodePack",
//                                                                         CFSTR("AES encrypt error! inputDataSize=%lu"),
//                                                                         v45,
//                                                                         v48);
//        goto LABEL_28;
    }
//    v33 = objc_msgSend(&OBJC_CLASS___MMServiceCenter, "defaultCenter");
//    v34 = (void *)objc_retainAutoreleasedReturnValue(v33);
//    v35 = objc_msgSend(&OBJC_CLASS___WCCalRqtDataMgr, "class");
//    v36 = objc_msgSend(v34, "getService:", v35);
//    v37 = (void *)objc_retainAutoreleasedReturnValue(v36);
//    v38 = objc_msgSend(v37, "calRqtData:len:cmd:", v52, v51, a9);
//    objc_release(v37);
//    objc_release(v34);
    sub_1035169F4((__int64) &v56, (__int64)v38);
    v39 = sub_1035168D8((__int64) &v56);
    sub_103517E0C(v39, v52, v51);
//    free(v52);
    sub_103517C9C((unsigned __int64 *)((char *)&v48 + 4));
    v40 = sub_103516A04((_DWORD *) &v54, (__int64)&v48 + 4);
    if ( (_DWORD)v40 )
    {
//        v41 = sub_1035168D0(&v56);
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         182LL,
//                                                                         "EncodePack",
//                                                                         CFSTR("mmpkg aes pack err, ret = %d, type = %d"),
//                                                                         v40,
//                                                                         v41);
//        v42 = 0LL;
    }
    else
    {
        LODWORD(v50) = 0;
        v47 = (void *)sub_103517EA0((__int64 **)((char *)&v44 + 4), (_DWORD *)&v44);
//        AutoBuffer::Attach(v49, v47, (signed int)v50);
        v49->Attach(v47, (signed int)v50);
        v42 = 1LL;
    }
    sub_103517D4C((__int64)&v44 + 4);
LABEL_29:
    sub_1035168A8((__int64) &v56);
    result = (long long)sub_103514094((void **) &v55);
//    if ( __stack_chk_guard == v57 )
//        result = v42;
    return result;
}

void ** EncodeRSAPack(AutoBuffer *a1, __int64 a2, __int64 a3, __int64 a4, __int64 a5, __int64 a6, const char *a7, unsigned int a8, unsigned int a9, const char *a10, unsigned int a11, unsigned int a12, unsigned __int8 a13)
{
    unsigned int v13; // w26
    const char *v14; // x27
    __int16 v15; // w28
    __int64 v16; // x22
    __int64 v17; // x23
    __int64 v18; // x25
    const Bytef *v19; // x20
    signed __int64 v20; // x0
    const char *v21; // x1
    __int64 v22; // x26
    int v23; // w0
    unsigned __int8 v24; // w8
    __int64 v25; // x19
    __int64 v26; // x0
    __int64 v27; // x19
    __int64 v28; // x0
    __int64 v29; // x0
    void *v30; // x0
    void *v31; // x19
    void *v32; // x0
    void *v33; // x0
    void *v34; // x20
    int v35; // w21
    __int64 v36; // x0
    __int64 v37; // x19
    __int64 v38; // x0
    void **v39; // x19
    void *v40; // x0
    void **result; // x0
    AutoBuffer *v42; // [xsp+50h] [xbp-F0h]
    unsigned __int64 v43; // [xsp+6Ch] [xbp-D4h]
    unsigned int v44; // [xsp+7Ch] [xbp-C4h]
    void *v45; // [xsp+80h] [xbp-C0h]
    __int16 v46; // [xsp+8Ch] [xbp-B4h]
    __int16 v47; // [xsp+8Eh] [xbp-B2h]
    char v48; // [xsp+90h] [xbp-B0h]
    char v49; // [xsp+A8h] [xbp-98h]
    __int64 v50; // [xsp+E8h] [xbp-58h]
    
    v13 = a8;
    v14 = a7;
    v15 = a6;
    v16 = a5;
    v17 = a4;
    v18 = a3;
    v19 = (const Bytef *)a2;
    v42 = a1;
    sub_103513FBC((__int64)&v48);
    v47 = 1;
    v46 = 1001;
    v20 = sub_1035146A4((const Bytef *)v19, (uLong) v18, (__int64)&v48, (unsigned __int16 *)&v47, (_WORD *)&v46);
    if ( ((unsigned int)v20 | 8) != 8 )
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         287LL,
//                                                                         "EncodeRSAPack",
//                                                                         CFSTR("compress rsa pack error! ret=%d, inLen=%u"),
//                                                                         v20,
//                                                                         v18);
    sub_103516854((__int64)&v49, 2);
    sub_1035169CC((__int64)&v49, 1);
    sub_1035169D4((__int64)&v49, 0);
    sub_1035168E0((__int64)&v49, a12);
    sub_1035168F8((__int64)&v49, a9);
    sub_1035168F0((__int64)&v49, a11);
    sub_1035169BC((__int64)&v49, v15);
    if ( v14 )
        v21 = v14;
    else
        v21 = "";
    sub_103516980(&v49, v21, v13);
//    nullsub_491();
    v22 = 0; //((unsigned __int16 (__cdecl *)(DeviceUtility_meta *, SEL))objc_msgSend)(
//                                                                                  (DeviceUtility_meta *)&OBJC_CLASS___DeviceUtility,
//                                                                                  "HeadDeviceType");
    sub_1035169C4((__int64)&v49, v22);
    sub_10351691C((__int64)&v49, v18);
    v23 = sub_10351418C((__int64)&v48);
    sub_103516924((__int64)&v49, v23);
    sub_103516934((__int64)&v49, v47);
//    nullsub_492(&v49, (unsigned int)v46);
    sub_10351690C((__int64)&v49, 1);
//    if ( byte_104C8A0A8 )
//        v24 = 8 * (byte_104C8A0A9 == 0);
//    else
//        v24 = 9;
//    v25 = v24;
    sub_1035169E4((__int64)&v49, v24);
    sub_1035169FC((__int64)&v49, a13);
    v26 = sub_10351418C((__int64)&v48);
//    +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                     &OBJC_CLASS___iConsole,
//                                                                     "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                     2LL,
//                                                                     0LL,
//                                                                     0LL,
//                                                                     "mmpack.mm",
//                                                                     333LL,
//                                                                     "EncodeRSAPack",
//                                                                     CFSTR("rsa pack cgi=%d, uin=%u, devideType=%u, compressLen=%u, compressedLen=%u, compressAlgo=%u, compressVer=%u, flag=%u"),
//                                                                     a11,
//                                                                     a9,
//                                                                     v22,
//                                                                     v18,
//                                                                     v26,
//                                                                     v47,
//                                                                     v46,
//                                                                     v25);
    v45 = 0LL;
    v44 = 0;
    if ( !v17 || !v16 )
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         343LL,
//                                                                         "EncodeRSAPack",
//                                                                         CFSTR("_keye:%s, _keyn:%s"),
//                                                                         v16,
//                                                                         v17);
    v27 = sub_10351419C((__int64)&v48);
    v28 = sub_10351418C((__int64)&v48);
//    v29 = rsa_public_encrypt(v27, v28, &v45, &v44, v17, v16);
    if (true /*!(_DWORD)v29 && v45 && v44*/)
    {
//        v30 = objc_msgSend(&OBJC_CLASS___MMServiceCenter, "defaultCenter");
//        v31 = (void *)objc_retainAutoreleasedReturnValue(v30);
//        v32 = objc_msgSend(&OBJC_CLASS___WCCalRqtDataMgr, "class");
//        v33 = objc_msgSend(v31, "getService:", v32);
//        v34 = (void *)objc_retainAutoreleasedReturnValue(v33);
//        v35 = (unsigned __int64)objc_msgSend(v34, "calRqtData:len:cmd:", v45, v44, a11);
//        objc_release(v34);
//        objc_release(v31);
        sub_1035169F4((__int64)&v49, v35);
        v36 = sub_1035168D8((__int64)&v49);
        sub_103517E0C(v36, v45, v44);
//        free(v45);
        v45 = 0LL;
        v44 = 0;
        sub_103517C9C((unsigned __int64 *)((char *)&v43 + 4));
        v37 = sub_103516A04((_DWORD *) &v49, (__int64)&v43 + 4);
        if (false/* (_DWORD)v37 */)
        {
//            v38 = sub_1035168D0(&v49);
//            +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                             &OBJC_CLASS___iConsole,
//                                                                             "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                             4LL,
//                                                                             0LL,
//                                                                             0LL,
//                                                                             "mmpack.mm",
//                                                                             375LL,
//                                                                             "EncodeRSAPack",
//                                                                             CFSTR("uin %u mmpkg rsa pack failed, ret %d, type %d"),
//                                                                             a9,
//                                                                             v37,
//                                                                             v38);
            v39 = 0LL;
        }
        else
        {
            LODWORD(v43) = 0;
            v40 = (void *)sub_103517EA0((__int64 **)((char *)&v43 + 4), (_DWORD *) &v43);
//            AutoBuffer::Attach(v42, v40, (signed int)v43);
            v42->Attach(v40, (signed int)v43);
            v39 = (void **)1;
        }
        sub_103517D4C((__int64)&v43 + 4);
    }
    else
    {
//        +[iConsole logWithLevel:module:errorCode:file:line:func:format:](
//                                                                         &OBJC_CLASS___iConsole,
//                                                                         "logWithLevel:module:errorCode:file:line:func:format:",
//                                                                         4LL,
//                                                                         0LL,
//                                                                         0LL,
//                                                                         "mmpack.mm",
//                                                                         357LL,
//                                                                         "EncodeRSAPack",
//                                                                         CFSTR("RSA encrypt error! ret=%d, rsaOutBuf=%p, rsaOutBufSize=%u"),
//                                                                         v29,
//                                                                         v45,
//                                                                         v44);
        v39 = 0LL;
    }
    sub_1035168A8((__int64)&v49);
    result = sub_103514094((void **)&v48);
//    if ( __stack_chk_guard == v50 )
//        result = v39;
    return result;
}
