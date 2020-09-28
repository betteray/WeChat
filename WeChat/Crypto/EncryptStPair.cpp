//
//  EncryptStPair.cpp
//  WeChat
//
//  Created by ray on 2020/9/4.
//  Copyright © 2020 ray. All rights reserved.
//

#include "EncryptStPair.hpp"
#include "defs.h"

int  encrypt_tag86(unsigned int a1)
{
    int v1; // r12
    int v2; // lr
    unsigned int v3; // r1

    v2 = 0;
    v3 = 0;
    do
    {
        if ( v3 > 8 || !((1 << v3) & 0x154) )
            v2 = (v1 & ~(((a1 >> v3) & 1) << v3) | (((a1 >> v3) & 1) << v3) & ~v1) ^ (v2 & ~v1 | v1 & ~v2) | ~(~(((a1 >> v3) & 1) << v3) | ~v2);
        ++v3;
    }
    while ( v3 != 32 );
    return v2;
}


unsigned int encrypt_tag90(int a1, int a2)
{
  unsigned int v2; // r1
  int v3; // r0

  v2 = ~(~(a2 >> (32 - a1 % 32)) | ~(a2 << a1 % 32)) | ((a2 >> (32 - a1 % 32)) & 0xDD519909 | ~(a2 >> (32 - a1 % 32)) & 0x22AE66F6) ^ ((a2 << a1 % 32) & 0xDD519909 | ~(a2 << a1 % 32) & 0x22AE66F6);
  v3 = a1 & ~v2 | v2 & ~a1;
  return v3 & (v3 ^ 0x3C0) & 0x40 | (v3 & (v3 ^ 0x3C0) & 0x286CF5A9 | ~(v3 & (v3 ^ 0x3C0)) & 0xD7930A56) ^ 0xD7930A16;
}

unsigned int  PkgHash3EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    unsigned int v3; // ST08_4
    unsigned int v4; // ST0C_4
    char v5; // r4
    int v6; // r11
    signed int v7; // r2
    char v8; // r5
    unsigned int v9; // r3
    unsigned int v10; // r0
    unsigned int v11; // r1
    unsigned int v12; // r0
    unsigned int v13; // r1
    unsigned int v14; // r0
    int v15; // r1

    v3 = a1;
    v4 = a3;
    v5 = a2;
    v6 = a2;
    v7 = -519174884 << (a2 & 0x1F);
    v8 = 32 - (a2 & 0x1F);
    v9 = (v7 & 0x299ADACF | ~v7 & 0xD6652530) ^ (~(0xE10E051C >> v8) & 0xD6652530 | (0xE10E051C >> v8) & 0x299ADACF);
    v10 = ~(~(0xE10E051C >> v8) | ~v7);
    v11 = ~(~(v3 << v8) | ~(v3 >> (v6 & 0x1F))) | ((v3 >> (v6 & 0x1F)) & 0x268F2035 | ~(v3 >> (v6 & 0x1F)) & 0xD970DFCA) ^ ((v3 << v8) & 0x268F2035 | ~(v3 << v8) & 0xD970DFCA);
    v12 = ~((v9 | v10) & ~v11 | v11 & ~(v9 | v10)) & 0xFB931A88 | ((v9 | v10) & ~v11 | v11 & ~(v9 | v10)) & 0x46CE577;
    LOBYTE(v11) = ((v5 + 1) ^ 0xE0) & (v5 + 1);
    v13 = ~(~(v4 >> (32 - v11)) | ~(v4 << v11)) | ((v4 << v11) & 0x66F2B54E | ~(v4 << v11) & 0x990D4AB1) ^ ((v4 >> (32 - v11)) & 0x66F2B54E | ~(v4 >> (32 - v11)) & 0x990D4AB1);
    v14 = v12 ^ (~v13 & 0xFB931A88 | v13 & 0x46CE577);
    v15 = ~v6 & 0x1F;
    return ~(~(v14 << (32 - v15)) | ~(v14 >> v15)) | ((v14 << (32 - v15)) & 0x464DE25B | ~(v14 << (32 - v15)) & 0xB9B21DA4) ^ (~(v14 >> v15) & 0xB9B21DA4 | (v14 >> v15) & 0x464DE25B);
}

unsigned int PkgHash3CrcPre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = ((a1 >> 32) & 0xA0FE43AC | ~(a1 >> 32) & 0x5F01BC53) ^ (a1 & 0xA0FE43AC | ~a1 & 0x5F01BC53) | ~(~(a1 >> 32) | ~a1);
  return v1 & 0x1EF1FAE3 | ~v1 & 0xE10E051C;
}

unsigned int  EntranceClassLoaderNameEncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r9
    unsigned int v4; // ST0A_4
    unsigned int v5; // ST14_4
    unsigned int v6; // r0
    int v7; // r2
    unsigned int v8; // r2
    int v9; // r3
    unsigned int v10; // r2
    int v11; // r0

    v4 = a1;
    v5 = a3;
    v6 = (a2 ^ 0xFFFFFFE0) & a2;
    v7 = (v3 | ~v3) & ~(~(v4 << (32 - v6)) | ~(v4 >> v6)) | ((v4 << (32 - v6)) & ~v3 | v3 & ~(v4 << (32 - v6))) ^ (v3 & ~(v4 >> v6) | (v4 >> v6) & ~v3);
    v8 = (~v7 & 0xA1498F5 | v7 & 0xF5EB670A) ^ (~((0xA50B0125 >> (32 - v6)) ^ (-1526005467 << v6) | (-1526005467 << v6) & (0xA50B0125 >> (32 - v6))) & 0xA1498F5 | ((0xA50B0125 >> (32 - v6)) ^ (-1526005467 << v6) | (-1526005467 << v6) & (0xA50B0125 >> (32 - v6))) & 0xF5EB670A);
    v9 = (v5 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) & (v5 << (((a2 + 1) ^ 0xE0) & (a2 + 1))) | (v5 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) ^ (v5 << (((a2 + 1) ^ 0xE0) & (a2 + 1)));
    v10 = (~v8 & 0x6D30B376 | v8 & 0x92CF4C89) ^ (~v9 & 0x6D30B376 | v9 & 0x92CF4C89);
    v11 = ~(_BYTE)v6 & 0x1F | 32 * (v6 >> 5);
    return ~(~(v10 << (32 - v11)) | ~(v10 >> v11)) | ((v10 << (32 - v11)) & 0xC17F5B17 | ~(v10 << (32 - v11)) & 0x3E80A4E8) ^ ((v10 >> v11) & 0xC17F5B17 | ~(v10 >> v11) & 0x3E80A4E8);
}

int  EntranceClassLoaderNameEncryptByte(unsigned int a1, int a2, unsigned char a3)
{
    unsigned int v3; // ST0A_4
    unsigned char v4; // ST14_1
    unsigned int v5; // r5
    unsigned int v6; // r0
    int v7; // r2
    unsigned int v8; // r0
    unsigned int v9; // r8
    int v10; // r0
    unsigned int v11; // r0
    char v12; // r1

    v3 = a1;
    v4 = a3;
    v5 = (a2 ^ 0xFFFFFFF8) & a2;
    v6 = (0x25u >> (8 - v5)) ^ (37 << v5) | (0x25u >> (8 - v5)) & (37 << v5);
    v7 = (v3 << (8 - v5)) & (v3 >> v5) | (v3 << (8 - v5)) ^ (v3 >> v5);
    v8 = (~v6 & 0x5F2AF76B | v6 & 0xA0D50894) ^ (~v7 & 0x5F2AF76B | v7 & 0xA0D50894);
    v9 = ~v8 & 0xC372D4D5 | v8 & 0x3C8D2B2A;
    v10 = (v4 >> (8 - (((a2 + 1) ^ 0xF8) & (a2 + 1)))) & (v4 << (((a2 + 1) ^ 0xF8) & (a2 + 1))) | (v4 >> (8 - (((a2 + 1) ^ 0xF8) & (a2 + 1)))) ^ (v4 << (((a2 + 1) ^ 0xF8) & (a2 + 1)));
    v11 = (unsigned char)((~(_BYTE)v10 & 0xD5 | v10 & 0x2A) ^ v9);
    v12 = (v5 & 0x8F | ~(_BYTE)v5 & 0x70) ^ 0x77;
    return (v11 << (8 - v12)) & (v11 >> v12) | (v11 << (8 - v12)) ^ (v11 >> v12);
}

// dalvik.system.PathClassLoader
unsigned int EntranceClassLoaderNameCrcPre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (2 * a1 & 0x8EB9DD7C | ~(2 * a1) & 0x71462283) ^ ((a1 >> 31) & 0x8EB9DD7C | ~(a1 >> 31) & 0x71462283) | ~(~(a1 >> 31) | ~(2 * a1));
  return ~v1 & 0xD2858092 | v1 & 0x2D7A7F6D;
}

// com.tencent.tinker.loader.TinkerClassLoader
unsigned int EntranceClassLoaderNameCrcPre2(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (8 * a1 & 0x8EB9DD7C | ~(8 * a1) & 0x71462283) ^ ((a1 >> 29) & 0x8EB9DD7C | ~(a1 >> 29) & 0x71462283) | ~(~(a1 >> 29) | ~(8 * a1));
  return ~v1 & 0xB4A16024 | v1 & 0x4B5E9FDB;
}

int  APKLeadingMD5EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r12
    int v4; // lr
    unsigned int v5; // ST14_4
    unsigned int v6; // r10
    unsigned int v7; // r0
    unsigned int v8; // r2
    int v9; // r3
    int v10; // r2
    int v11; // r1
    unsigned int v12; // r1
    int v13; // r0

    v5 = a3;
    v6 = a1;
    v7 = (a2 ^ 0xFFFFFFE0) & a2;
    v8 = (-770963655 << v7) & (0xD20C0739 >> (32 - v7)) | (0xD20C0739 >> (32 - v7)) ^ (-770963655 << v7);
    v9 = (v6 << (32 - v7)) & (v6 >> v7) | (v6 << (32 - v7)) ^ (v6 >> v7);
    v10 = (v4 & ~v8 | v8 & ~v4) ^ (v4 & ~v9 | v9 & ~v4);
    v11 = (v5 >> (32 - ((a2 + 1) & 0x1F))) & (v5 << ((a2 + 1) & 0x1F)) | (v5 >> (32 - ((a2 + 1) & 0x1F))) ^ (v5 << ((a2 + 1) & 0x1F));
    v12 = (v3 & ~v11 | v11 & ~v3) ^ (v3 & ~v10 | v10 & ~v3);
    v13 = ~(_BYTE)v7 & 0x1F | 32 * (v7 >> 5);
    return (v12 << (32 - v13)) & (v12 >> v13) | (v12 << (32 - v13)) ^ (v12 >> v13);
}

unsigned int APKLeadingMD5CrcPre(unsigned int a1)
{
  int v1; // r0

  v1 = a1 & (a1 >> 32) | (a1 >> 32) ^ a1;
  return ~v1 & 0xD20C0739 | v1 & 0x2DF3F8C6;
}

unsigned int  AppInstrumentationClassNameEncryptWord(unsigned int key, char round, unsigned int plain)
{
    unsigned int v3; // r6
    unsigned int v4; // r0
    int v5; // r3
    unsigned int v6; // r12
    unsigned int v7; // r0
    unsigned int v8; // r0
    char v9; // r1

    v3 = key;
    v4 = (0xB9070842 >> (32 - round)) & (-1190721470 << round) | (0xB9070842 >> (32 - round)) ^ (-1190721470 << round);
    v5 = (v3 >> round) & (v3 << (32 - round)) | (v3 << (32 - round)) ^ (v3 >> round);
    v6 = ~(v4 & ~v5 | v5 & ~v4) & 0xCB72ED02 | (v4 & ~v5 | v5 & ~v4) & 0x348D12FD;
    LOBYTE(v5) = (round + 1) & 0x1F;
    v7 = (~(plain << v5) & 0x3E50B23 | (plain << v5) & 0xFC1AF4DC) ^ ((plain >> (32 - v5)) & 0xFC1AF4DC | ~(plain >> (32 - v5)) & 0x3E50B23) | ~(~(plain >> (32 - v5)) | ~(plain << v5));
    v8 = (~v7 & 0xCB72ED02 | v7 & 0x348D12FD) ^ v6;
    v9 = (round & 0x6D | (~round | 0xE0) & 0x92) ^ 0x8D;
    return ~(~(v8 << (32 - v9)) | ~(v8 >> v9)) | ((v8 << (32 - v9)) & 0x402BA505 | ~(v8 << (32 - v9)) & 0xBFD45AFA) ^ ((v8 >> v9) & 0x402BA505 | ~(v8 >> v9) & 0xBFD45AFA);
}

unsigned int  AppInstrumentationClassNameEncryptByte(unsigned int key, char round, unsigned int byt)
{
    int v3; // r12
    int v4; // lr
    char v5; // r6
    unsigned int v6; // ST04_4
    char v7; // r9
    char v8; // r4
    int v9; // r0
    unsigned int v10; // r1
    int v11; // r2
    int v12; // r0
    int v13; // r1
    int v14; // r0

    v5 = round;
    v6 = byt;
    v7 = round;
    v8 = round & 7;
    v9 = (key << (8 - v8)) & (key >> v8) | (key << (8 - v8)) ^ (key >> v8);
    v10 = (v4 | ~v4) & ~(~(0x42u >> (8 - v8)) | ~(66 << v8)) | (v4 & ~(0x42u >> (8 - v8)) | (0x42u >> (8 - v8)) & ~v4) ^ ((66 << v8) & ~v4 | v4 & ~(66 << v8));
    v11 = v9 & ~v10;
    v12 = v10 & ~v9;
    ++v5;
    v13 = (v3 | ~v3) & ~(~(v6 >> (8 - (v5 & 7))) | ~(v6 << (v5 & 7))) | ((v6 << (v5 & 7)) & ~v3 | v3 & ~(v6 << (v5 & 7))) ^ ((v6 >> (8 - (v5 & 7))) & ~v3 | v3 & ~(v6 >> (8 - (v5 & 7))));
    v14 = v13 & ~(v12 | v11) | (v12 | v11) & ~v13;
    unsigned int result = ((v14 & (v14 ^ 0xFFFFFF00)) << (8 - (~v7 & 7))) & ((v14 & (v14 ^ 0xFFFFFF00)) >> (~v7 & 7)) | ((v14 & (v14 ^ 0xFFFFFF00)) << (8 - (~v7 & 7))) ^ ((v14 & (v14 ^ 0xFFFFFF00)) >> (~v7 & 7));

    return result & 0xff;
}

unsigned int AppInstrumentationClassNameCrcPre(unsigned int a1)
{
  int v1; // r1

  v1 = 8 * a1 & (a1 >> 29) | (a1 >> 29) ^ 8 * a1;
  return ~v1 & 0x5720E108 | v1 & 0xA8DF1EF7;
}

int  AMSBinderClassNameEncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r8
    int v4; // r9
    int v5; // lr
    unsigned int v6; // ST0A_4
    unsigned int v7; // ST14_4
    int v8; // r4
    unsigned int v9; // r0
    unsigned int v10; // r1
    int v11; // r2
    int v12; // r1
    int v13; // r2
    unsigned int v14; // r1

    v6 = a1;
    v7 = a3;
    v8 = a2;
    v9 = (v8 ^ 0xFFFFFFE0) & v8;
    v10 = (v5 | ~v5) & ~(~(0x280D0852u >> (32 - v9)) | ~(671942738 << v9)) | ((671942738 << v9) & ~v5 | v5 & ~(671942738 << v9)) ^ ((0x280D0852u >> (32 - v9)) & ~v5 | v5 & ~(0x280D0852u >> (32 - v9)));
    v11 = (v4 | ~v4) & ~(~(v6 << (32 - v9)) | ~(v6 >> v9)) | ((v6 << (32 - v9)) & ~v4 | v4 & ~(v6 << (32 - v9))) ^ (v4 & ~(v6 >> v9) | (v6 >> v9) & ~v4);
    v12 = v10 & ~v11 | v11 & ~v10;
    v13 = (v7 >> (32 - ((v8 + 1) & 0x1F))) & (v7 << ((v8 + 1) & 0x1F)) | (v7 >> (32 - ((v8 + 1) & 0x1F))) ^ (v7 << ((v8 + 1) & 0x1F));
    v14 = v13 & ~v12 | v12 & ~v13;
    LOBYTE(v9) = (~(_BYTE)v9 & 0x6E | v9 & 0x91) ^ 0x71;
    return (v3 | ~v3) & ~(~(v14 << (32 - v9)) | ~(v14 >> v9)) | ((v14 << (32 - v9)) & ~v3 | v3 & ~(v14 << (32 - v9))) ^ ((v14 >> v9) & ~v3 | v3 & ~(v14 >> v9));
}

unsigned int  AMSBinderClassNameEncryptByte(unsigned int a1, char a2, unsigned char a3)
{
    unsigned int v3; // ST0E_4
    char v4; // ST1C_1
    char v5; // r9
    char v6; // r11
    unsigned int v7; // r0
    unsigned int v8; // r1
    unsigned int v9; // r0
    unsigned int v10; // r1
    unsigned int v11; // r0

    v3 = a1;
    v4 = a2;
    v5 = a2;
    v6 = a2 & 7;
    v7 = (~(82 << v6) & 0x9348A25D | (82 << v6) & 0x6CB75DA2) ^ ((0x52u >> (8 - v6)) & 0x6CB75DA2 | ~(0x52u >> (8 - v6)) & 0x9348A25D) | ~(~(0x52u >> (8 - v6)) | ~(82 << v6));
    v8 = ~(~(v3 << (8 - v6)) | ~(v3 >> v6)) | ((v3 >> v6) & 0x6E4E8051 | ~(v3 >> v6) & 0x91B17FAE) ^ ((v3 << (8 - v6)) & 0x6E4E8051 | ~(v3 << (8 - v6)) & 0x91B17FAE);
    v9 = (~v8 & 0x233651CC | v8 & 0xDCC9AE33) ^ (~v7 & 0x233651CC | v7 & 0xDCC9AE33);
    LOBYTE(v8) = ((v5 + 1) ^ 0xF8) & (v5 + 1);
    v10 = ~(~(a3 >> (8 - v8)) | ~(a3 << v8)) | ((a3 >> (8 - v8)) & 0x1D011240 | ~(a3 >> (8 - v8)) & 0xE2FEEDBF) ^ ((a3 << v8) & 0x1D011240 | ~(a3 << v8) & 0xE2FEEDBF);
    v11 = (~v9 & 0x5ED4 | v9 & 0xFFFFA12B) ^ (~v10 & 0x5ED4 | v10 & 0xFFFFA12B);
    LOBYTE(v10) = (v6 & 0xD6 | (~v4 | 0xF8) & 0x29) ^ 0x2E;
    unsigned  int result = ((v11 & (v11 ^ 0xFFFFFF00)) << (8 - v10)) & ((v11 & (v11 ^ 0xFFFFFF00)) >> v10) | ((v11 & (v11 ^ 0xFFFFFF00)) << (8 - v10)) ^ ((v11 & (v11 ^ 0xFFFFFF00)) >> v10);
    return result & 0xFF;
}

unsigned int  AMSBinderClassNameCrcPre(unsigned int a1)
{
    unsigned int v1; // r0

    v1 = (4 * a1 & 0x17054018 | ~(4 * a1) & 0xE8FABFE7) ^ ((a1 >> 30) & 0x17054018 | ~(a1 >> 30) & 0xE8FABFE7) | ~(~(a1 >> 30) | ~(4 * a1));
    return ~v1 & 0x8A034214 | v1 & 0x75FCBDEB;
}

int  AMSSingletonClassNameEncryptWord(unsigned int key, unsigned int round, unsigned int plain)
{
    int v4; // r9
    int v5; // lr
    unsigned int v6; // r6
    char v7; // r4
    unsigned int v8; // r0
    char v9; // r2
    int v10; // r1
    unsigned int v11; // r2
    int v12; // r12
    int v13; // r2
    int v14; // t1
    unsigned int v15; // r12
    int v16; // r3
    int v17; // r1
    unsigned int v18; // r2
    int v19; // r5
    unsigned int v20; // r1
    int v21; // r0
    unsigned int v23; // [sp+8h] [bp+0h]

    v23 = plain;
    v6 = key;
    v7 = round;
    v8 = round;
    v9 = 32 - round;
    v10 = (v6 >> round) & (v6 << v9) | (v6 << v9) ^ (v6 >> round);
    v11 = 0xE1020567 >> v9;
    v12 = v4 & ~v11;
    v13 = (v4 | ~v4) & ~(~v11 | ~(-519961241 << v8)) | (v11 & ~v4 | v12) ^ ((-519961241 << v8) & ~v4 | v4 & ~(-519961241 << v8));
//    v14 = *(_DWORD *)(v12 + 1216);
    v15 = (~v10 & 0xF269CBD7 | v10 & 0xD963428) ^ (~v13 & 0xF269CBD7 | v13 & 0xD963428);
    v16 = plain << (++v7 & 0x1F);
    v17 = v5 & ~v16 | v16 & ~v5;
    v18 = v23 >> (32 - (v7 & 0x1F));
    v19 = v18 & ~v5 | v5 & ~v18;
    v20 = (v17 ^ v19 | (v5 | ~v5) & ~(~v18 | ~v16)) & ~v15 | v15 & ~(v17 ^ v19 | (v5 | ~v5) & ~(~v18 | ~v16));
    v21 = ~(_BYTE)v8 & 0x1F | 32 * (v8 >> 5);
    return (v20 << (32 - v21)) & (v20 >> v21) | (v20 << (32 - v21)) ^ (v20 >> v21);
}


unsigned int  AMSSingletonClassNameEncryptByte(unsigned int a1, int a2, unsigned int a3)
{
    unsigned int v3; // ST0E_4
    unsigned int v4; // r4
    unsigned int v5; // r0
    int v6; // r2
    unsigned int v7; // r11
    unsigned int v8; // r0
    int v9; // r0
    unsigned int v10; // r0
    unsigned int v11; // r1
    unsigned int v13; // [sp+12h] [bp+0h]

    v3 = a1;
    v13 = a3;
    v4 = (a2 ^ 0xFFFFFFF8) & a2;
    v5 = (0x67u >> (8 - v4)) ^ (103 << v4) | (0x67u >> (8 - v4)) & (103 << v4);
    v6 = (v3 << (8 - v4)) & (v3 >> v4) | (v3 << (8 - v4)) ^ (v3 >> v4);
    v7 = (~v6 & 0xD05D693E | v6 & 0x2FA296C1) ^ (~v5 & 0xD05D693E | v5 & 0x2FA296C1);
    LOBYTE(v6) = ((a2 + 1) ^ 0xF8) & (a2 + 1);
    v8 = (~(v13 >> (8 - v6)) & 0xD3A60CDD | (v13 >> (8 - v6)) & 0x2C59F322) ^ (~(v13 << v6) & 0xD3A60CDD | (v13 << v6) & 0x2C59F322) | ~(~(v13 >> (8 - v6)) | ~(v13 << v6));
    v9 = v8 & ~v7 | v7 & ~v8;
    v10 = v9 & (v9 ^ 0xFFFFFF00);
    v11 = (v4 & 0xC2F62BC | ~v4 & 0xF3D09D43) ^ 0xF3D09D44;
    return ~(~(v10 << (8 - v11)) | ~(v10 >> v11)) | ((v10 << (8 - v11)) & 0x9C755FAC | ~(v10 << (8 - v11)) & 0x638AA053) ^ (~(v10 >> v11) & 0x638AA053 | (v10 >> v11) & 0x9C755FAC);
}

unsigned int AMSSingletonClassNameCrcPre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (8 * a1 & 0xFFFF3280 | ~(8 * a1) & 0xCD7F) ^ ((a1 >> 29) & 0xFFFF3280 | ~(a1 >> 29) & 0xCD7F) | ~(~(a1 >> 29) | ~(8 * a1));
  return ~v1 & 0xFC2040AC | v1 & 0x3DFBF53;
}

int  ApkSignatureMd5EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r10
    int v4; // r11
    char v5; // r3
    int v6; // r0
    unsigned int v7; // r8
    unsigned int v8; // r0
    unsigned int v9; // r0
    int v10; // r2
    unsigned int v11; // r0
    unsigned int v12; // r1

    v4 = a2;
    v5 = 32 - (a2 & 0x1F);
    v6 = (a1 << v5) ^ (a1 >> (v4 & 0x1F)) | (a1 >> (v4 & 0x1F)) & (a1 << v5);
    v7 = ~v6 & 0x9D840A5C | v6 & 0x627BF5A3;
    v8 = (v3 & ~(0xA50E0673 >> v5) | (0xA50E0673 >> v5) & ~v3) ^ ((-1525807501 << (v4 & 0x1F)) & ~v3 | v3 & ~(-1525807501 << (v4 & 0x1F))) | (v3 | ~v3) & ~(~(0xA50E0673 >> v5) | ~(-1525807501 << (v4 & 0x1F)));
    v9 = (~v8 & 0x9D840A5C | v8 & 0x627BF5A3) ^ v7;
    v10 = (a3 >> (32 - ((a2 + 1) & 0x1F))) & (a3 << ((a2 + 1) & 0x1F)) | (a3 >> (32 - ((a2 + 1) & 0x1F))) ^ (a3 << ((a2 + 1) & 0x1F));
    v11 = (~v9 & 0x658CBAB4 | v9 & 0x9A73454B) ^ (~v10 & 0x658CBAB4 | v10 & 0x9A73454B);
    v12 = (v4 & 5 | (~v4 | 0xFFFFFFE0) & 0x5D39535A) ^ 0x5D395345;
    return (v11 << (32 - v12)) & (v11 >> v12) | (v11 << (32 - v12)) ^ (v11 >> v12);
}

unsigned int ApkSignatureMd5CrcPre(unsigned int a1)
{
   unsigned int v1; // r0

   v1 = (a1 & 0x76F9379 | ~a1 & 0xF8906C86) ^ ((a1 >> 32) & 0x76F9379 | ~(a1 >> 32) & 0xF8906C86) | ~(~(a1 >> 32) | ~a1);
   return ~v1 & 0xA50E0673 | v1 & 0x5AF1F98C;
}

int  SystemFrameworkMD5EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r10
    int v4; // lr
    unsigned int v5; // r11
    char v6; // r4
    unsigned int v7; // r1
    unsigned int v8; // r0
    int v9; // r3
    int v10; // r3
    char v11; // r5
    unsigned int v12; // r2
    unsigned int v13; // r1

    v5 = a1;
    v6 = a2;
    v7 = (a2 ^ 0xFFFFFFE0) & a2;
    v8 = (-1056111739 << v7) & (0xC10D0385 >> (32 - v7)) | (0xC10D0385 >> (32 - v7)) ^ (-1056111739 << v7);
    v9 = (v5 >> v7) & (v5 << (32 - v7)) | (v5 << (32 - v7)) ^ (v5 >> v7);
    v10 = (v3 & ~v9 | v9 & ~v3) ^ (v3 & ~v8 | v8 & ~v3);
    v11 = ((v6 + 1) ^ 0xE0) & (v6 + 1);
    v12 = ((a3 >> (32 - v11)) & (a3 << v11) | (a3 >> (32 - v11)) ^ (a3 << v11)) & ~v10 | v10 & ~((a3 >> (32 - v11)) & (a3 << v11) | (a3 >> (32 - v11)) ^ (a3 << v11));
    v13 = (v4 & ~v7 | v7 & ~v4) ^ (v4 & 0xFFFFFFE0 | ~(_BYTE)v4 & 0x1F);
    return (v12 << (32 - v13)) & (v12 >> v13) | (v12 << (32 - v13)) ^ (v12 >> v13);
}

unsigned int SystemFrameworkMD5CrcPre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (a1 & 0xFFFFD8C5 | ~a1 & 0x273A) ^ ((a1 >> 32) & 0xFFFFD8C5 | ~(a1 >> 32) & 0x273A) | ~(~(a1 >> 32) | ~a1);
  return ~v1 & 0xC10D0385 | v1 & 0x3EF2FC7A;
}

int  SystemFrameworkArmMD5Word(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r9
    int v4; // r10
    unsigned int v5; // ST0A_4
    unsigned int v6; // ST14_4
    int v7; // r11
    char v8; // r3
    unsigned int v9; // r0
    int v10; // r2
    int v11; // r0
    int v12; // r2
    unsigned int v13; // r0
    unsigned int v14; // r1

    v5 = a1;
    v6 = a3;
    v7 = a2;
    v8 = 32 - (a2 & 0x1F);
    v9 = (0xE20A0595 >> v8) ^ (-502659691 << (v7 & 0x1F)) | (-502659691 << (v7 & 0x1F)) & (0xE20A0595 >> v8);
    v10 = (v4 | ~v4) & ~(~(v5 << v8) | ~(v5 >> (v7 & 0x1F))) | (v4 & ~(v5 << v8) | (v5 << v8) & ~v4) ^ (v4 & ~(v5 >> (v7 & 0x1F)) | (v5 >> (v7 & 0x1F)) & ~v4);
    v11 = v9 & ~v10 | v10 & ~v9;
    v12 = (v6 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) & (v6 << (((a2 + 1) ^ 0xE0) & (a2 + 1))) | (v6 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) ^ (v6 << (((a2 + 1) ^ 0xE0) & (a2 + 1)));
    v13 = (v3 & ~v11 | v11 & ~v3) ^ (v3 & ~v12 | v12 & ~v3);
    v14 = (v7 & 0x18 | (~v7 | 0xFFFFFFE0) & 0x796CDB47) ^ 0x796CDB58;
    return (v13 << (32 - v14)) & (v13 >> v14) | (v13 << (32 - v14)) ^ (v13 >> v14);
}

unsigned int SystemFrameworkArmMD5CrcPre(unsigned int a1)
{
  return (~((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0xB613C4E4 | ((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0x49EC3B1B) ^ 0x5419C171;
}

int  SystemFrameworkArm64MD5EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r8
    int v4; // r9
    int v5; // lr
    unsigned int v6; // ST0A_4
    unsigned int v7; // ST14_4
    char v8; // r4
    unsigned int v9; // r0
    unsigned int v10; // r1
    int v11; // r2
    unsigned int v12; // r12
    int v13; // r1
    unsigned int v14; // r1
    int v15; // r0

    v6 = a1;
    v7 = a3;
    v8 = a2;
    v9 = (a2 ^ 0xFFFFFFE0) & a2;
    v10 = (-1542781531 << v9) & (0xA40B05A5 >> (32 - v9)) | (0xA40B05A5 >> (32 - v9)) ^ (-1542781531 << v9);
    v11 = (v4 | ~v4) & ~(~(v6 << (32 - v9)) | ~(v6 >> v9)) | ((v6 << (32 - v9)) & ~v4 | v4 & ~(v6 << (32 - v9))) ^ ((v6 >> v9) & ~v4 | v4 & ~(v6 >> v9));
    v12 = (~v11 & 0x9C4914B | v11 & 0xF63B6EB4) ^ (~v10 & 0x9C4914B | v10 & 0xF63B6EB4);
    LOBYTE(v11) = (v8 + 1) & 0x1F;
    v13 = (v5 & ~(v7 << v11) | (v7 << v11) & ~v5) ^ ((v7 >> (32 - v11)) & ~v5 | v5 & ~(v7 >> (32 - v11))) | (v5 | ~v5) & ~(~(v7 >> (32 - v11)) | ~(v7 << v11));
    v14 = v13 & ~v12 | v12 & ~v13;
    v15 = ~(_BYTE)v9 & 0x1F | 32 * (v9 >> 5);
    return (v3 | ~v3) & ~(~(v14 << (32 - v15)) | ~(v14 >> v15)) | ((v14 << (32 - v15)) & ~v3 | v3 & ~(v14 << (32 - v15))) ^ ((v14 >> v15) & ~v3 | v3 & ~(v14 >> v15));
}

unsigned int SystemFrameworkArm64MD5CrcPre(unsigned int a1)
{
  int v1; // r0

  v1 = a1 & (a1 >> 32) | (a1 >> 32) ^ a1;
  return (~v1 & 0xF42E3CCD | v1 & 0xBD1C332) ^ 0x50253968;
}

int  SystemBinMD5EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    int v3; // r8
    unsigned int v4; // ST0A_4
    int v5; // r4
    unsigned int v6; // r1
    unsigned int v7; // r0
    unsigned int v8; // r2
    int v9; // r3
    int v10; // r2
    int v11; // r1
    unsigned int v12; // r1

    v4 = a1;
    v5 = a2;
    v6 = a3;
    v7 = (v5 ^ 0xFFFFFFE0) & v5;
    v8 = (-1257306701 << v7) & (0xB50F05B3 >> (32 - v7)) | (0xB50F05B3 >> (32 - v7)) ^ (-1257306701 << v7);
    LOBYTE(v5) = v5 + 1;
    v9 = (v4 << (32 - v7)) & (v4 >> v7) | (v4 << (32 - v7)) ^ (v4 >> v7);
    v10 = v8 & ~v9 | v9 & ~v8;
    v11 = (v3 | ~v3) & ~(~(v6 >> (32 - (v5 & 0x1F))) | ~(v6 << (v5 & 0x1F))) | ((v6 >> (32 - (v5 & 0x1F))) & ~v3 | v3 & ~(v6 >> (32 - (v5 & 0x1F)))) ^ ((v6 << (v5 & 0x1F)) & ~v3 | v3 & ~(v6 << (v5 & 0x1F)));
    v12 = (~v11 & 0x5FABF790 | v11 & 0xA054086F) ^ (~v10 & 0x5FABF790 | v10 & 0xA054086F);
    LOBYTE(v7) = (~(_BYTE)v7 & 0x2F | v7 & 0xD0) ^ 0x30;
    return (v12 << (32 - v7)) & (v12 >> v7) | (v12 << (32 - v7)) ^ (v12 >> v7);
}

unsigned int SystemBinMD5CrcPre(unsigned int a1)
{
  int v1; // r1

  v1 = a1 & (a1 >> 32) | (a1 >> 32) ^ a1;
  return ~v1 & 0xB50F05B3 | v1 & 0x4AF0FA4C;
}

int  StorageIDEncryptWord(unsigned int key, int round, unsigned int plain)
{
    char v3; // r12
    int v4; // lr
    unsigned int v5; // ST04_4
    unsigned int v6; // r10
    unsigned int v7; // r0
    unsigned int v8; // r2
    int v9; // r3
    int v10; // r2
    int v11; // r1
    unsigned int v12; // r1

    v5 = plain;
    v6 = key;
    v7 = (round ^ 0xFFFFFFE0) & round;
    v8 = (-503118395 << v7) & (0xE20305C5 >> (32 - v7)) | (0xE20305C5 >> (32 - v7)) ^ (-503118395 << v7);
    v9 = (v6 << (32 - v7)) & (v6 >> v7) | (v6 << (32 - v7)) ^ (v6 >> v7);
    v10 = (v4 & ~v8 | v8 & ~v4) ^ (v4 & ~v9 | v9 & ~v4);
    v11 = (v5 >> (32 - ((round + 1) & 0x1F))) & (v5 << ((round + 1) & 0x1F)) | (v5 >> (32 - ((round + 1) & 0x1F))) ^ (v5 << ((round + 1) & 0x1F));
    v12 = v11 & ~v10 | v10 & ~v11;
    LOBYTE(v7) = (v3 & ~(_BYTE)v7 | v7 & ~v3) ^ (v3 & 0xE0 | ~v3 & 0x1F);
    return (v12 << (32 - v7)) & (v12 >> v7) | (v12 << (32 - v7)) ^ (v12 >> v7);
}


unsigned int StorageIDCrcPre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (a1 & 0x3F430E84 | ~a1 & 0xC0BCF17B) ^ ((a1 >> 32) & 0x3F430E84 | ~(a1 >> 32) & 0xC0BCF17B) | ~(~(a1 >> 32) | ~a1);
  return ~v1 & 0xE20305C5 | v1 & 0x1DFCFA3A;
}

int  encrypt_tag117(unsigned int a1)
{
    int v1; // r10
    int v2; // r1
    signed int v3; // r2
    unsigned int v4; // r3

    v1 = 0x1000000;
    v2 = 0;
    v3 = -1;
    do
    {
        if ( ((v2 & 0xB4EC0EE4 | v3 & 0x4B13F11B) ^ 0x4B13F10B | ~v3 & 0x10) != 24 )
        {
            v4 = ((a1 >> v2) & ((a1 >> v2) ^ 0xFFFFFFFE)) << v2;
            v1 = v4 & v1 | v4 ^ v1;
        }
        ++v2;
        --v3;
    }
    while ( v2 != 32 );
    return v1;
}

unsigned int  SourceDirEncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    unsigned int v3; // ST0A_4
    char v4; // r4
    unsigned int v5; // r0
    unsigned int v6; // r1
    int v7; // r3
    unsigned int v8; // r3
    int v9; // r2
    unsigned int v10; // r2
    int v11; // r0

    v3 = a1;
    v4 = a2;
    v5 = (a2 ^ 0xFFFFFFE0) & a2;
    v6 = (-1795095344 << v5) & (0x950104D0 >> (32 - v5)) | (0x950104D0 >> (32 - v5)) ^ (-1795095344 << v5);
    v7 = (v3 >> v5) & (v3 << (32 - v5)) | (v3 << (32 - v5)) ^ (v3 >> v5);
    v8 = (~v7 & 0x247DA805 | v7 & 0xDB8257FA) ^ (~v6 & 0x247DA805 | v6 & 0xDB8257FA);
    v9 = (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) & (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1))) | (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) ^ (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1)));
    v10 = v9 & ~v8 | v8 & ~v9;
    v11 = ~(_BYTE)v5 & 0x1F | 32 * (v5 >> 5);
    return ~(~(v10 << (32 - v11)) | ~(v10 >> v11)) | ((v10 << (32 - v11)) & 0x80275949 | ~(v10 << (32 - v11)) & 0x7FD8A6B6) ^ ((v10 >> v11) & 0x80275949 | ~(v10 >> v11) & 0x7FD8A6B6);
}

unsigned int  SourceDirEncryptByte(int a1, __int16 a2, unsigned char a3)
{
    __int64 v3; // ST0A_8
    char v4; // r6
    int v5; // r11
    unsigned int v6; // r12
    unsigned int v7; // r1
    int v8; // r0
    unsigned int v9; // r1
    unsigned int v10; // r0
    unsigned int v11; // r0
    unsigned int v12; // r1

    LODWORD(v3) = a1;
    WORD2(v3) = a2;
    v4 = a2;
    v5 = a2 & 7;
    v6 = (~(208 << v5) & 0xE957A341 | (208 << v5) & 0x16A85CBE) ^ ((0xD0u >> (8 - v5)) & 0x16A85CBE | ~(0xD0u >> (8 - v5)) & 0xE957A341) | ~(~(0xD0u >> (8 - v5)) | ~(208 << v5));
    v7 = ~(~((_DWORD)v3 << (8 - v5)) | ~((unsigned int)v3 >> v5)) | (((unsigned int)v3 >> v5) & 0xD8BA8265 | ~((unsigned int)v3 >> v5) & 0x27457D9A) ^ (((_DWORD)v3 << (8 - v5)) & 0xD8BA8265 | ~((_DWORD)v3 << (8 - v5)) & 0x27457D9A);
    v8 = v6 & ~v7 | v7 & ~v6;
    LOBYTE(v7) = ((v4 + 1) ^ 0xF8) & (v4 + 1);
    v9 = ~(~(a3 >> (8 - v7)) | ~(a3 << v7)) | ((a3 << v7) & 0x3A3CE333 | ~(a3 << v7) & 0xC5C31CCC) ^ ((a3 >> (8 - v7)) & 0x3A3CE333 | ~(a3 >> (8 - v7)) & 0xC5C31CCC);
    v10 = (~v8 & 0xA792DF18 | v8 & 0x586D20E7) ^ (~v9 & 0xA792DF18 | v9 & 0x586D20E7);
    v11 = v10 & (v10 ^ 0xFFFFFF00);
    v12 = (v5 & 0x1E1381A5 | (~*(_DWORD *)((char *)&v3 + 2) | 0xFFFFFFF8) & 0xE1EC7E5A) ^ 0xE1EC7E5D;
    unsigned int result = ~(~(v11 << (8 - v12)) | ~(v11 >> v12)) | ((v11 << (8 - v12)) & 0xFFFF715B | ~(v11 << (8 - v12)) & 0x8EA4) ^ (~(v11 >> v12) & 0x8EA4 | (v11 >> v12) & 0xFFFF715B);
    return result & 0xff;
}

unsigned int SourceDirCrcPre(unsigned int a1)
{
  int v1; // r6
  unsigned int v2; // r0

  v2 = (4 * a1 & 0x6393FF4C | ~(4 * a1) & 0x9C6C00B3) ^ ((a1 >> 30) & 0x6393FF4C | ~(a1 >> 30) & 0x9C6C00B3) | ~(~(a1 >> 30) | ~(4 * a1));
  return (~(v1 | 0xDABFBECB) | 0x25404134) & ~v2 | v2 & ~(~(v1 | 0xDABFBECB) | 0x25404134);
}

int  SourceDir2EncryptWord(unsigned int a1, int a2, unsigned int a3)
{
    unsigned int v3; // ST0A_4
    unsigned int v4; // ST14_4
    unsigned int v5; // r0
    unsigned int v6; // r2
    unsigned int v7; // r9
    unsigned int v8; // r2
    unsigned int v9; // r2
    int v10; // r3
    unsigned int v11; // r2
    int v12; // r0

    v3 = a1;
    v4 = a3;
    v5 = (a2 ^ 0xFFFFFFE0) & a2;
    v6 = (~(1644429802 << v5) & 0xCB6D5136 | (1644429802 << v5) & 0x3492AEC9) ^ ((0x620401EAu >> (32 - v5)) & 0x3492AEC9 | ~(0x620401EAu >> (32 - v5)) & 0xCB6D5136) | ~(~(0x620401EAu >> (32 - v5)) | ~(1644429802 << v5));
    v7 = ~v6 & 0xFE0F5B2D | v6 & 0x1F0A4D2;
    v8 = (~(v3 << (32 - v5)) & 0xDBC7C374 | (v3 << (32 - v5)) & 0x24383C8B) ^ (~(v3 >> v5) & 0xDBC7C374 | (v3 >> v5) & 0x24383C8B) | ~(~(v3 << (32 - v5)) | ~(v3 >> v5));
    v9 = (~v8 & 0xFE0F5B2D | v8 & 0x1F0A4D2) ^ v7;
    v10 = (v4 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) & (v4 << (((a2 + 1) ^ 0xE0) & (a2 + 1))) | (v4 >> (32 - (((a2 + 1) ^ 0xE0) & (a2 + 1)))) ^ (v4 << (((a2 + 1) ^ 0xE0) & (a2 + 1)));
    v11 = v10 & ~v9 | v9 & ~v10;
    v12 = ~(_BYTE)v5 & 0x1F | 32 * (v5 >> 5);
    return (v11 << (32 - v12)) & (v11 >> v12) | (v11 << (32 - v12)) ^ (v11 >> v12);
}

///////////////////////////////////////////

unsigned int  SourceDir2EncryptByte(unsigned int a1, char a2, unsigned char a3)
{
    char v3; // r9
    char v4; // r4
    int v5; // r0
    unsigned int v6; // r0
    int v7; // r1

    v3 = a2;
    v4 = a2 & 7;
    v5 = (a1 << (8 - v4)) | (a1 >> v4);
    v6 = ~v5 ^ ~((234 << v4) | (0xEAu >> (8 - v4)) );
    v7 = (a3 >> (8 - (((a2 + 1) ^ 0xF8) & (a2 + 1)))) | (a3 << (((a2 + 1) ^ 0xF8) & (a2 + 1)));
    LOBYTE(v6) = (~(_BYTE)v6 & 0xFE | v6 & 1) ^ (~(_BYTE)v7 & 0xFE | v7 & 1);
    LOBYTE(v7) = (v3 & 3 | (~v3 | 0xF8) & 0x64) ^ 0x63;
    unsigned int result =  ~(~((unsigned char)v6 << (8 - v7)) | ~((unsigned int)(unsigned char)v6 >> v7)) | (((unsigned char)v6 << (8 - v7))  ^  0x4A246CB9) ^ (((unsigned int)(unsigned char)v6 >> v7) ^ 0x4A246CB9);

    return result & 0xff;
}

unsigned int SourceDir2CrcPre(unsigned int a1)
{
  return ((a1 >> 30) & 4 * a1 | (a1 >> 30) ^ 4 * a1) & 0x677EFF85 | ~((a1 >> 30) & 4 * a1 | (a1 >> 30) ^ 4 * a1) & 0x9881007A;
}


unsigned int ProcSelfMountsCheck(int a1, int a2)
{
    int v2; // r2

  v2 = a1 & ~(a2 * a1) | a2 * a1 & ~a1;
  return (~(v2 & (v2 ^ 0x48)) & 0x5E1154A2 | v2 & (v2 ^ 0x48) & 0xA1EEAB5D) ^ 0x5E1154E2 | ~(~(v2 & (v2 ^ 0x48)) | 0xFFFFFFBF);
}
