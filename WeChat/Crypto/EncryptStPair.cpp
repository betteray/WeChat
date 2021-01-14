//
//  EncryptStPair.cpp
//  WeChat
//
//  Created by ray on 2020/9/4.
//  Copyright © 2020 ray. All rights reserved.
//

#include "EncryptStPair.hpp"

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

unsigned int StorageIDEncryptByte(unsigned int a1, int a2, unsigned __int8 a3)
{
  unsigned int v3; // ST0C_4
  int v4; // ST10_4
  char v5; // r10
  char v6; // r4
  unsigned int v7; // r0
  unsigned int v8; // r1
  unsigned int v9; // r0
  unsigned int v10; // r1
  unsigned int v11; // r0
  unsigned int v12; // r0
  int v13; // r1

  v3 = a1;
  v4 = a2;
  v5 = a2;
  v6 = a2 & 7;
  v7 = (~(0xC5u >> (8 - v6)) & 0x3D6E705 | (0xC5u >> (8 - v6)) & 0xFC2918FA) ^ (~(197 << (a2 & 7)) & 0x3D6E705 | (197 << (a2 & 7)) & 0xFC2918FA) | ~(~(0xC5u >> (8 - v6)) | ~(197 << (a2 & 7)));
  v8 = ~(~(v3 << (8 - v6)) | ~(v3 >> v6)) | ((v3 >> v6) & 0x1A8218FA | ~(v3 >> v6) & 0xE57DE705) ^ ((v3 << (8 - v6)) & 0x1A8218FA | ~(v3 << (8 - v6)) & 0xE57DE705);
  v9 = ~(v7 & ~v8 | v8 & ~v7) & 0x52B19E90 | (v7 & ~v8 | v8 & ~v7) & 0xAD4E616F;
  LOBYTE(v8) = ((v5 + 1) ^ 0xF8) & (v5 + 1);
  v10 = ~(~(a3 >> (8 - v8)) | ~(a3 << v8)) | ((a3 << v8) & 0xE6269AF7 | ~(a3 << v8) & 0x19D96508) ^ ((a3 >> (8 - v8)) & 0xE6269AF7 | ~(a3 >> (8 - v8)) & 0x19D96508);
  v11 = v9 ^ (~v10 & 0x52B19E90 | v10 & 0xAD4E616F);
  v12 = v11 & (v11 ^ 0xFFFFFF00);
  v13 = ~v4 & 7;
  return ~(~(v12 << (8 - v13)) | ~(v12 >> v13)) | ((v12 << (8 - v13)) & 0x4DEC7D03 | ~(v12 << (8 - v13)) & 0xB21382FC) ^ ((v12 >> v13) & 0x4DEC7D03 | ~(v12 >> v13) & 0xB21382FC);
}

unsigned int StorageIDCrcPre(unsigned int a1, int a2)
{
  unsigned int v2; // r1
  unsigned int v3; // r2

  v2 = (a2 ^ 0xFFFFFFFC) & a2;
  v3 = (-503118395 << (32 - v2)) & (0xE20305C5 >> v2) | (-503118395 << (32 - v2)) ^ (0xE20305C5 >> v2);
  return (~((a1 >> (32 - v2)) & (a1 << v2) | (a1 >> (32 - v2)) ^ (a1 << v2)) & 0x35664E71 | ((a1 >> (32 - v2)) & (a1 << v2) | (a1 >> (32 - v2)) ^ (a1 << v2)) & 0xCA99B18E) ^ (~v3 & 0x35664E71 | v3 & 0xCA99B18E);
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

unsigned int StackTraceEncrypt_Word(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // r11
  int v4; // r12
  unsigned int v5; // r5
  unsigned int v6; // r8
  int v7; // r0
  int v8; // r0
  int v9; // r2
  int v10; // r3
  int v11; // r0
  unsigned int v12; // r2

  v5 = (a2 ^ 0xFFFFFFE0) & a2;
  v6 = (v4 & ~(0xE7081A05 >> (32 - v5)) | (0xE7081A05 >> (32 - v5)) & ~v4) ^ ((-418899451 << v5) & ~v4 | v4 & ~(-418899451 << v5)) | (v4 | ~v4) & ~(~(0xE7081A05 >> (32 - v5)) | ~(-418899451 << v5));
  v7 = (v3 | ~v3) & ~(~(a1 << (32 - v5)) | ~(a1 >> v5)) | (v3 & ~(a1 << (32 - v5)) | (a1 << (32 - v5)) & ~v3) ^ (v3 & ~(a1 >> v5) | (a1 >> v5) & ~v3);
  v8 = v6 & ~v7 | v7 & ~v6;
  v9 = (a3 >> (32 - ((a2 + 1) & 0x1F))) & (a3 << ((a2 + 1) & 0x1F)) | (a3 >> (32 - ((a2 + 1) & 0x1F))) ^ (a3 << ((a2 + 1) & 0x1F));
  v10 = v8 & ~v9;
  v11 = v9 & ~v8;
  v12 = (v5 & 0x36522402 | ~v5 & 0xC9ADDBFD) ^ 0xC9ADDBE2;
  return ((v11 | v10) << (32 - v12)) & ((v11 | (unsigned int)v10) >> v12) | ((v11 | v10) << (32 - v12)) ^ ((v11 | (unsigned int)v10) >> v12);
}

unsigned int StackTraceEncrypt_Byte(unsigned int a1, int a2, unsigned __int8 a3)
{
  int v3; // r9
  unsigned int v4; // r4
  unsigned int v5; // r10
  int v6; // r0
  int v7; // r0
  char v8; // r3
  int v9; // r0
  char v10; // r2

  v4 = (a2 ^ 0xFFFFFFF8) & a2;
  v5 = (5 << v4) & (5u >> (8 - v4)) | (5u >> (8 - v4)) ^ (5 << v4);
  v6 = (v3 & ~(a1 << (8 - v4)) | (a1 << (8 - v4)) & ~v3) ^ (v3 & ~(a1 >> v4) | (a1 >> v4) & ~v3) | (v3 | ~v3) & ~(~(a1 << (8 - v4)) | ~(a1 >> v4));
  v7 = v5 & ~v6 | v6 & ~v5;
  LOBYTE(v5) = ~(_BYTE)v7 & 0x40 | v7 & 0xBF;
  v8 = ((a2 + 1) ^ 0xF8) & (a2 + 1);
  v9 = a3 << v8;
  LOBYTE(v9) = (~(v9 & ((unsigned int)a3 >> (8 - v8)) | ((unsigned int)a3 >> (8 - v8)) ^ v9) & 0x40 | (v9 & ((unsigned int)a3 >> (8 - v8)) | ((unsigned int)a3 >> (8 - v8)) ^ v9) & 0xBF) ^ v5;
  v10 = (v4 & 0x8C | ~(_BYTE)v4 & 0x73) ^ 0x74;
  return ~(~((unsigned __int8)v9 << (8 - v10)) | ~((unsigned int)(unsigned __int8)v9 >> v10)) | (((unsigned __int8)v9 << (8 - v10)) & 0xFFFF4DA3 | ~((unsigned __int8)v9 << (8 - v10)) & 0xB25C) ^ (((unsigned int)(unsigned __int8)v9 >> v10) & 0xFFFF4DA3 | ~((unsigned int)(unsigned __int8)v9 >> v10) & 0xB25C);
}

unsigned int StackTraceCrc_Pre(unsigned int a1)
{
  int v1; // r1

  v1 = 8 * a1 & (a1 >> 29) | (a1 >> 29) ^ 8 * a1;
  return ~v1 & 0xBCE10340 | v1 & 0x431EFCBF;
}

unsigned int  ServiceListMd5Encrypt(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // lr
  unsigned int v4; // ST14_4
  unsigned int v5; // r9
  unsigned int v6; // r2
  unsigned int v7; // r12
  unsigned int v8; // r2
  unsigned int v9; // r2
  char v10; // r3
  unsigned int v11; // r1
  int v12; // r3

  v4 = a3;
  v5 = (a2 ^ v3) & a2;
  v6 = ~(~(0x810D1917 >> (32 - v5)) | ~(-2129848041 << v5)) | (~(0x810D1917 >> (32 - v5)) & 0x57BDEF29 | (0x810D1917 >> (32 - v5)) & 0xA84210D6) ^ (~(-2129848041 << v5) & 0x57BDEF29 | (-2129848041 << v5) & 0xA84210D6);
  v7 = ~v6 & 0x41B0 | v6 & 0xFFFFBE4F;
  v8 = (~(a1 << (32 - v5)) & 0x4C55 | (a1 << (32 - v5)) & 0xFFFFB3AA) ^ ((a1 >> v5) & 0xFFFFB3AA | ~(a1 >> v5) & 0x4C55) | ~(~(a1 << (32 - v5)) | ~(a1 >> v5));
  v9 = (~v8 & 0x41B0 | v8 & 0xFFFFBE4F) ^ v7;
  v10 = (a2 + 1) & ((a2 + 1) ^ 0xE0);
  v11 = ((v4 >> (32 - v10)) & (v4 << v10) | (v4 >> (32 - v10)) ^ (v4 << v10)) & ~v9 | v9 & ~((v4 >> (32 - v10)) & (v4 << v10) | (v4 >> (32 - v10)) ^ (v4 << v10));
  v12 = ~(_BYTE)v5 & 0x1F | 32 * (v5 >> 5);
  return (v11 << (32 - v12)) & (v11 >> v12) | (v11 << (32 - v12)) ^ (v11 >> v12);
}

unsigned int ServiceListMd5Crc_Pre(unsigned int a1)
{
  int v1; // r3
  unsigned int v2; // r0

  HIWORD(v1) = -29474;
  v2 = (a1 & ~v1 | v1 & ~a1) ^ ((a1 >> 32) & ~v1 | v1 & ~(a1 >> 32)) | ~(~(a1 >> 32) | ~a1);
  return ~v2 & 0x810D1917 | v2 & 0x7EF2E6E8;
}

unsigned int SystemAppMD5Encrypt(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST0A_4
  unsigned int v4; // ST14_4
  char v5; // r0
  unsigned int v6; // r1
  int v7; // r9
  unsigned int v8; // r3
  int v9; // r2
  int v10; // r5
  unsigned int v11; // r9
  unsigned int v12; // r3
  unsigned int v13; // r2
  int v14; // r1

  v3 = a1;
  v4 = a3;
  v5 = a2;
  v6 = (a2 ^ 0xFFFFFFE0) & a2;
  v7 = (v3 >> v6) & (v3 << (32 - v6)) | (v3 << (32 - v6)) ^ (v3 >> v6);
  v8 = ~(~(0x120A1728u >> (32 - v6)) | ~(302651176 << v6)) | ((0x120A1728u >> (32 - v6)) & 0x4191896C | ~(0x120A1728u >> (32 - v6)) & 0xBE6E7693) ^ (~(302651176 << v6) & 0xBE6E7693 | (302651176 << v6) & 0x4191896C);
  v9 = v8 & ~v7 | v7 & ~v8;
  LOBYTE(v8) = (v5 + 1) & 0x1F;
  v10 = v4 << v8;
  v11 = ~(v4 << v8) & 0x69011B89 | (v4 << v8) & 0x96FEE476;
  v12 = v4 >> (32 - v8);
  v13 = (~((~v12 & 0x69011B89 | v12 & 0x96FEE476) ^ v11 | ~(~v12 | ~v10)) & 0x519EFE3A | ((~v12 & 0x69011B89 | v12 & 0x96FEE476) ^ v11 | ~(~v12 | ~v10)) & 0xAE6101C5) ^ (~v9 & 0x519EFE3A | v9 & 0xAE6101C5);
  v14 = ~(_BYTE)v6 & 0x1F | 32 * (v6 >> 5);
  return ~(~(v13 << (32 - v14)) | ~(v13 >> v14)) | ((v13 << (32 - v14)) & 0xA6D1C918 | ~(v13 << (32 - v14)) & 0x592E36E7) ^ ((v13 >> v14) & 0xA6D1C918 | ~(v13 >> v14) & 0x592E36E7);
}

unsigned int SystemAppMD5Crc_Pre(unsigned int a1)
{
  int v1; // r0

  v1 = a1 & (a1 >> 32) | (a1 >> 32) ^ a1;
  return ~v1 & 0x120A1728 | v1 & 0xEDF5E8D7;
}

unsigned int SystemPrivAppMD5Encrypt(unsigned int a1, char a2, unsigned int a3)
{
  char v3; // ST10_1
  char v4; // r9
  char v5; // r10
  unsigned int v6; // r8
  unsigned int v7; // r1
  int v8; // r0
  int v9; // r1
  unsigned int v10; // r0

  v3 = a2;
  v4 = a2;
  v5 = a2 & 0x1F;
  v6 = (~(-1409083850 << v5) & 0x9626ECE2 | (-1409083850 << v5) & 0x69D9131D) ^ (~(0xAC031636 >> (32 - v5)) & 0x9626ECE2 | (0xAC031636 >> (32 - v5)) & 0x69D9131D) | ~(~(0xAC031636 >> (32 - v5)) | ~(-1409083850 << v5));
  v7 = (~(a1 << (32 - v5)) & 0x4DC7A8F7 | (a1 << (32 - v5)) & 0xB2385708) ^ (~(a1 >> v5) & 0x4DC7A8F7 | (a1 >> v5) & 0xB2385708) | ~(~(a1 << (32 - v5)) | ~(a1 >> v5));
  v8 = v6 & ~v7 | v7 & ~v6;
  v9 = (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) & (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1))) | (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) ^ (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1)));
  v10 = (~v8 & 0x15B9CE51 | v8 & 0xEA4631AE) ^ (~v9 & 0x15B9CE51 | v9 & 0xEA4631AE);
  LOBYTE(v9) = (v5 & 0xD4 | (~v3 | 0xE0) & 0x2B) ^ 0x34;
  return ~(~(v10 << (32 - v9)) | ~(v10 >> v9)) | ((v10 << (32 - v9)) & 0x76B7A930 | ~(v10 << (32 - v9)) & 0x894856CF) ^ ((v10 >> v9) & 0x76B7A930 | ~(v10 >> v9) & 0x894856CF);
}

unsigned int SystemPrivAppMD5Crc_Pre(unsigned int a1)
{
  return (~(a1 & (a1 >> 32) | (a1 >> 32) ^ a1) & 0x2DAF997C | (a1 & (a1 >> 32) | (a1 >> 32) ^ a1) & 0xD2506683) ^ 0x81AC8F4A;
}

unsigned int VendorAppMD5Encrypt(unsigned int a1, char a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  char v4; // r9
  unsigned int v5; // r0
  unsigned int v6; // r12
  unsigned int v7; // r0
  unsigned int v8; // r0
  unsigned int v9; // ST14_4
  char v10; // r5
  unsigned int v11; // r0
  unsigned int v12; // r0
  char v13; // r1

  v3 = a1;
  v4 = a2 & 0x1F;
  v5 = (0xBD021341 >> (32 - v4)) & (-1123937471 << v4) | (0xBD021341 >> (32 - v4)) ^ (-1123937471 << v4);
  v6 = ~v5 & 0x85E5CCB5 | v5 & 0x7A1A334A;
  v7 = ((v3 << (32 - v4)) & 0x69354D | ~(v3 << (32 - v4)) & 0xFF96CAB2) ^ ((v3 >> v4) & 0x69354D | ~(v3 >> v4) & 0xFF96CAB2) | ~(~(v3 << (32 - v4)) | ~(v3 >> v4));
  v8 = (~v7 & 0x85E5CCB5 | v7 & 0x7A1A334A) ^ v6;
  v9 = ~v8 & 0x68194C8F | v8 & 0x97E6B370;
  v10 = ((a2 + 1) ^ 0xE0) & (a2 + 1);
  v11 = ((a3 << v10) & 0x3A7BC7AC | ~(a3 << v10) & 0xC5843853) ^ ((a3 >> (32 - v10)) & 0x3A7BC7AC | ~(a3 >> (32 - v10)) & 0xC5843853) | ~(~(a3 >> (32 - v10)) | ~(a3 << v10));
  v12 = (~v11 & 0x68194C8F | v11 & 0x97E6B370) ^ v9;
  v13 = (a2 & 0x18 | (~a2 | 0xE0) & 0xA7) ^ 0xB8;
  return (v12 << (32 - v13)) & (v12 >> v13) | (v12 << (32 - v13)) ^ (v12 >> v13);
}

unsigned int VendorAppMD5Crc_Pre(unsigned int a1)
{
  return (~((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0x47C60DE4 | ((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0xB839F21B) ^ 0xFAC41EA5;
}

unsigned int ProductAppMD5Encrypt(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  char v4; // r10
  unsigned int v5; // r0
  unsigned int v6; // r1
  int v7; // r3
  int v8; // r1
  int v9; // r2
  unsigned int v10; // r2

  v3 = a1;
  v4 = a2;
  v5 = (a2 ^ 0xFFFFFFE0) & a2;
  v6 = (604772434 << v5) & (0x240C1852u >> (32 - v5)) | (0x240C1852u >> (32 - v5)) ^ (604772434 << v5);
  v7 = (v3 >> v5) & (v3 << (32 - v5)) | (v3 << (32 - v5)) ^ (v3 >> v5);
  v8 = v6 & ~v7 | v7 & ~v6;
  v9 = (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) & (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1))) | (a3 >> (32 - (((v4 + 1) ^ 0xE0) & (v4 + 1)))) ^ (a3 << (((v4 + 1) ^ 0xE0) & (v4 + 1)));
  v10 = (~v9 & 0xEDD2A081 | v9 & 0x122D5F7E) ^ (~v8 & 0xEDD2A081 | v8 & 0x122D5F7E);
  LOBYTE(v5) = (~(_BYTE)v5 & 0x4B | v5 & 0xB4) ^ 0x54;
  return (v10 << (32 - v5)) & (v10 >> v5) | (v10 << (32 - v5)) ^ (v10 >> v5);
}

unsigned int ProductAppMD5Crc_Pre(unsigned int a1)
{
  unsigned int v3; // r0
  int a3 = 0;

  v3 = (a1 & 0xAFA94AA2 | ~a1 & 0x5056B55D) ^ ((a1 >> a3) & 0xAFA94AA2 | ~(a1 >> a3) & 0x5056B55D) | ~(~(a1 >> a3) | ~a1);
  return ~v3 & 0x240C1852 | v3 & 0xDBF3E7AD;
}

unsigned int SystemBinLsEncrypt(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // r11
  char v4; // r9
  int v5; // r1
  unsigned int v6; // r12
  unsigned int v7; // r1
  unsigned int v8; // r1
  char v9; // r0
  unsigned int v10; // r1
  int v11; // r2

  v3 = a2;
  v4 = 32 - (a2 & 0x1F);
  v5 = (a1 << v4) & (a1 >> (v3 & 0x1F)) | (a1 << v4) ^ (a1 >> (v3 & 0x1F));
  v6 = ~v5 & 0x138811A5 | v5 & 0xEC77EE5A;
  v7 = (~(0x250A1954u >> v4) & 0xE60EB3C0 | (0x250A1954u >> v4) & 0x19F14C3F) ^ ((621418836 << (v3 & 0x1F)) & 0x19F14C3F | ~(621418836 << (v3 & 0x1F)) & 0xE60EB3C0) | ~(~(0x250A1954u >> v4) | ~(621418836 << (v3 & 0x1F)));
  v8 = (~v7 & 0x138811A5 | v7 & 0xEC77EE5A) ^ v6;
  v9 = v3 + 1;
  v10 = (~v8 & 0xAB286562 | v8 & 0x54D79A9D) ^ (~((a3 >> (32 - (v9 & 0x1F))) & (a3 << (v9 & 0x1F)) | (a3 >> (32 - (v9 & 0x1F))) ^ (a3 << (v9 & 0x1F))) & 0xAB286562 | ((a3 >> (32 - (v9 & 0x1F))) & (a3 << (v9 & 0x1F)) | (a3 >> (32 - (v9 & 0x1F))) ^ (a3 << (v9 & 0x1F))) & 0x54D79A9D);
  v11 = ~v3 & 0x1F;
  return ~(~(v10 << (32 - v11)) | ~(v10 >> v11)) | ((v10 << (32 - v11)) & 0xE22CDF6E | ~(v10 << (32 - v11)) & 0x1DD32091) ^ (~(v10 >> v11) & 0x1DD32091 | (v10 >> v11) & 0xE22CDF6E);
}

unsigned int SystemBinLsCrc_Pre(int a1, int a2)
{
  unsigned int v2; // ST08_4
  char v3; // r0
  unsigned int v4; // r3
  unsigned int v5; // r0

  v2 = a1;
  v3 = a2 & 3;
  v4 = v2 >> (32 - (a2 & 3));
  v5 = ((0x250A1954u >> v3) & 0x4A08977B | ~(0x250A1954u >> v3) & 0xB5F76884) ^ ((621418836 << (32 - v3)) & 0x4A08977B | ~(621418836 << (32 - v3)) & 0xB5F76884) | ~(~(621418836 << (32 - v3)) | ~(0x250A1954u >> v3));
  return (~((v2 << (a2 & 3)) & v4 | v4 ^ (v2 << (a2 & 3))) & 0x873993EF | ((v2 << (a2 & 3)) & v4 | v4 ^ (v2 << (a2 & 3))) & 0x78C66C10) ^ (~v5 & 0x873993EF | v5 & 0x78C66C10);
}

unsigned int SystemFrameworkFrameworkResEncrypt(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // r9
  int v4; // r10
  unsigned int v5; // ST08_4
  char v6; // r0
  unsigned int v7; // r1
  int v8; // r3
  unsigned int v9; // r12
  int v10; // r2
  unsigned int v11; // r2

  v5 = a1;
  v6 = a2;
  v7 = (a2 ^ 0xFFFFFFE0) & a2;
  ++v6;
  v8 = (v5 << (32 - v7)) ^ (v5 >> v7) | (v5 << (32 - v7)) & (v5 >> v7);
  v9 = (~((1728779105 << v7) & (0x670B1361u >> (32 - v7)) | (0x670B1361u >> (32 - v7)) ^ (1728779105 << v7)) & 0x2F223E6 | ((1728779105 << v7) & (0x670B1361u >> (32 - v7)) | (0x670B1361u >> (32 - v7)) ^ (1728779105 << v7)) & 0xFD0DDC19) ^ (~v8 & 0x2F223E6 | v8 & 0xFD0DDC19);
  v10 = (v4 | ~v4) & ~(~(a3 >> (32 - (v6 & 0x1F))) | ~(a3 << (v6 & 0x1F))) | (v4 & ~(a3 >> (32 - (v6 & 0x1F))) | (a3 >> (32 - (v6 & 0x1F))) & ~v4) ^ (v4 & ~(a3 << (v6 & 0x1F)) | (a3 << (v6 & 0x1F)) & ~v4);
  v11 = v10 & ~v9 | v9 & ~v10;
  LOBYTE(v7) = (~(_BYTE)v7 & 0xE7 | v7 & 0x18) ^ 0xF8;
  return (v3 | ~v3) & ~(~(v11 << (32 - v7)) | ~(v11 >> v7)) | ((v11 << (32 - v7)) & ~v3 | v3 & ~(v11 << (32 - v7))) ^ ((v11 >> v7) & ~v3 | v3 & ~(v11 >> v7));
}

unsigned int SystemFrameworkFrameworkResCrc_Pre(unsigned int a1)
{
  unsigned int v1; // r0

  v1 = (a1 & 0xC8D28564 | ~a1 & 0x372D7A9B) ^ ((a1 >> 32) & 0xC8D28564 | ~(a1 >> 32) & 0x372D7A9B) | ~(~(a1 >> 32) | ~a1);
  return (~v1 & 0x5A008A5 | v1 & 0xFA5FF75A) ^ 0x62AB1BC4;
}

unsigned int SystemLibLibcPlusPlusEncrypt(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  unsigned int v4; // ST10_4
  unsigned int v5; // r0
  unsigned int v6; // r2
  unsigned int v7; // r8
  unsigned int v8; // r2
  unsigned int v9; // r2
  int v10; // r3
  unsigned int v11; // r2

  v3 = a1;
  v4 = a3;
  v5 = (a2 ^ 0xFFFFFFE0) & a2;
  v6 = (1376588914 << v5) & (0x520D1472u >> (32 - v5)) | (0x520D1472u >> (32 - v5)) ^ (1376588914 << v5);
  v7 = ~v6 & 0xB6C87AE | v6 & 0xF4937851;
  v8 = ~(~(v3 << (32 - v5)) | ~(v3 >> v5)) | ((v3 << (32 - v5)) & 0x17EE0F4A | ~(v3 << (32 - v5)) & 0xE811F0B5) ^ (~(v3 >> v5) & 0xE811F0B5 | (v3 >> v5) & 0x17EE0F4A);
  v9 = (~v8 & 0xB6C87AE | v8 & 0xF4937851) ^ v7;
  v10 = (v4 >> (32 - ((a2 + 1) & 0x1F))) & (v4 << ((a2 + 1) & 0x1F)) | (v4 >> (32 - ((a2 + 1) & 0x1F))) ^ (v4 << ((a2 + 1) & 0x1F));
  v11 = v10 & ~v9 | v9 & ~v10;
  LOBYTE(v5) = (~(_BYTE)v5 & 0xCE | v5 & 0x31) ^ 0xD1;
  return (v11 << (32 - v5)) & (v11 >> v5) | (v11 << (32 - v5)) ^ (v11 >> v5);
}

unsigned int SystemLibLibcPlusPlusCrc_Pre(unsigned int a1)
{
  return ((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0xADF2EB8D | ~((a1 >> 32) & a1 | (a1 >> 32) ^ a1) & 0x520D1472;
}

unsigned int SystemBinLinkerEncrypt(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  char v4; // r0
  unsigned int v5; // r1
  unsigned int v6; // r5
  int v7; // r3
  int v8; // r8
  unsigned int v9; // r2
  unsigned int v10; // r2
  unsigned int v11; // r1

  v3 = a1;
  v4 = a2;
  v5 = (a2 ^ 0xFFFFFFE0) & a2;
  v6 = (0x830C1175 >> (32 - v5)) & (-2096361099 << v5) | (0x830C1175 >> (32 - v5)) ^ (-2096361099 << v5);
  v7 = (v3 << (32 - v5)) & (v3 >> v5) | (v3 << (32 - v5)) ^ (v3 >> v5);
  v8 = v6 & ~v7 | v7 & ~v6;
  LOBYTE(v6) = (v4 + 1) & ((v4 + 1) ^ 0xE0);
  v9 = ~(~(a3 >> (32 - v6)) | ~(a3 << v6)) | (~(a3 >> (32 - v6)) & 0x39B4F6D9 | (a3 >> (32 - v6)) & 0xC64B0926) ^ (~(a3 << v6) & 0x39B4F6D9 | (a3 << v6) & 0xC64B0926);
  v10 = v9 & ~v8 | v8 & ~v9;
  v11 = (~v5 & 0x4DF7880 | v5 & 0xFB20877F) ^ 0x4DF789F;
  return ~(~(v10 << (32 - v11)) | ~(v10 >> v11)) | ((v10 << (32 - v11)) & 0xDF3408E3 | ~(v10 << (32 - v11)) & 0x20CBF71C) ^ ((v10 >> v11) & 0xDF3408E3 | ~(v10 >> v11) & 0x20CBF71C);
}

unsigned int SystemBinLinkerCrc_Pre(int a1)
{
  return (~a1 & 0xB545E5D8 | a1 & 0x4ABA1A27) ^ 0x3649F4AD;
}

unsigned int RootEncrypt_Word(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  char v4; // r9
  unsigned int v5; // r1
  unsigned int v6; // r0
  unsigned int v7; // r12
  unsigned int v8; // r0
  unsigned int v9; // r12
  char v10; // r4
  int v11; // r3
  unsigned int v12; // r2
  unsigned int v13; // r0

  v3 = a1;
  v4 = a2;
  v5 = (a2 ^ 0xFFFFFFE0) & a2;
  v6 = ~(~(0xEC061286 >> (32 - v5)) | ~(-335146362 << v5)) | (~(0xEC061286 >> (32 - v5)) & 0xA71F8B57 | (0xEC061286 >> (32 - v5)) & 0x58E074A8) ^ (~(-335146362 << v5) & 0xA71F8B57 | (-335146362 << v5) & 0x58E074A8);
  v7 = ~v6 & 0x1C2D003A | v6 & 0xE3D2FFC5;
  v8 = (~(v3 << (32 - v5)) & 0x87748462 | (v3 << (32 - v5)) & 0x788B7B9D) ^ ((v3 >> v5) & 0x788B7B9D | ~(v3 >> v5) & 0x87748462) | ~(~(v3 << (32 - v5)) | ~(v3 >> v5));
  v9 = v7 ^ (~v8 & 0x1C2D003A | v8 & 0xE3D2FFC5);
  v10 = ((v4 + 1) ^ 0xE0) & (v4 + 1);
  v11 = a3 << v10;
  v12 = a3 >> (32 - v10);
  v13 = ((~v11 & 0xD60CC7F2 | v11 & 0x29F3380D) ^ (v12 & 0x29F3380D | ~v12 & 0xD60CC7F2) | ~(~v12 | ~v11)) & ~v9 | v9 & ~((~v11 & 0xD60CC7F2 | v11 & 0x29F3380D) ^ (v12 & 0x29F3380D | ~v12 & 0xD60CC7F2) | ~(~v12 | ~v11));
  LOBYTE(v5) = (~(_BYTE)v5 & 0xE | v5 & 0xF1) ^ 0x11;
  return ~(~(v13 << (32 - v5)) | ~(v13 >> v5)) | ((v13 << (32 - v5)) & 0x717FECB3 | ~(v13 << (32 - v5)) & 0x8E80134C) ^ ((v13 >> v5) & 0x717FECB3 | ~(v13 >> v5) & 0x8E80134C);
}

unsigned int RootEncrypt_Byte(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST10_4
  char v4; // r5
  int v5; // r9
  char v6; // r2
  unsigned int v7; // r1
  int v8; // r0
  int v9; // r2
  int v10; // r0
  int v11; // r1
  int v12; // r1

  v3 = a3;
  v4 = a2;
  v5 = a2;
  v6 = a2 & 7;
  v7 = (0x86u >> (8 - v6)) ^ (134 << v6) | (0x86u >> (8 - v6)) & (134 << v6);
  v8 = (a1 << (8 - v6)) & (a1 >> v6) | (a1 << (8 - v6)) ^ (a1 >> v6);
  v9 = v8 & ~v7;
  v10 = v7 & ~v8;
  ++v4;
  v11 = (v3 >> (8 - ((v4 ^ 0xF8) & v4))) & (v3 << ((v4 ^ 0xF8) & v4)) | (v3 >> (8 - ((v4 ^ 0xF8) & v4))) ^ (v3 << ((v4 ^ 0xF8) & v4));
  LOBYTE(v10) = (~(v10 | v9) & 0xAA | (v10 | v9) & 0x55) ^ (~(_BYTE)v11 & 0xAA | v11 & 0x55);
  v12 = ~v5 & 7;
  return ~(~((unsigned __int8)v10 << (8 - v12)) | ~((unsigned int)(unsigned __int8)v10 >> v12)) | (((unsigned __int8)v10 << (8 - v12)) & 0x9193DAB3 | ~((unsigned __int8)v10 << (8 - v12)) & 0x6E6C254C) ^ (((unsigned int)(unsigned __int8)v10 >> v12) & 0x9193DAB3 | ~((unsigned int)(unsigned __int8)v10 >> v12) & 0x6E6C254C);
}

unsigned int RootCrc_Pre(unsigned int a1, char a2)
{
  unsigned int v2; // ST08_4
  char v3; // r0
  signed int v4; // r3

  v2 = a1;
  v3 = (a2 ^ 0xFC) & a2;
  v4 = -335146362 << (32 - v3);
  return (~((0xEC061286 >> v3) & v4 | v4 ^ (0xEC061286 >> v3)) & 0xFE9C9FD5 | ((0xEC061286 >> v3) & v4 | v4 ^ (0xEC061286 >> v3)) & 0x163602A) ^ (~((v2 << v3) & (v2 >> (32 - v3)) | (v2 >> (32 - v3)) ^ (v2 << v3)) & 0xFE9C9FD5 | ((v2 << v3) & (v2 >> (32 - v3)) | (v2 >> (32 - v3)) ^ (v2 << v3)) & 0x163602A);
}

unsigned int SystemEncrypt_Word(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  unsigned int v4; // ST10_4
  char v5; // r0
  unsigned int v6; // r1
  unsigned int v7; // r12
  unsigned int v8; // r2
  int v9; // r2
  int v10; // r3
  unsigned int v11; // r2

  v3 = a1;
  v4 = a3;
  v5 = a2;
  v6 = (a2 ^ 0xFFFFFFE0) & a2;
  v7 = (~(0x670F1A9Bu >> (32 - v6)) & 0xE57D0EF7 | (0x670F1A9Bu >> (32 - v6)) & 0x1A82F108) ^ (~(1729043099 << v6) & 0xE57D0EF7 | (1729043099 << v6) & 0x1A82F108) | ~(~(0x670F1A9Bu >> (32 - v6)) | ~(1729043099 << v6));
  v8 = (~(v3 << (32 - v6)) & 0xDF63961F | (v3 << (32 - v6)) & 0x209C69E0) ^ ((v3 >> v6) & 0x209C69E0 | ~(v3 >> v6) & 0xDF63961F) | ~(~(v3 << (32 - v6)) | ~(v3 >> v6));
  v9 = v7 & ~v8 | v8 & ~v7;
  v10 = (v4 >> (32 - ((v5 + 1) & 0x1F))) & (v4 << ((v5 + 1) & 0x1F)) | (v4 >> (32 - ((v5 + 1) & 0x1F))) ^ (v4 << ((v5 + 1) & 0x1F));
  v11 = v10 & ~v9 | v9 & ~v10;
  LOBYTE(v6) = (~(_BYTE)v6 & 0xBF | v6 & 0x40) ^ 0xA0;
  return (v11 << (32 - v6)) & (v11 >> v6) | (v11 << (32 - v6)) ^ (v11 >> v6);
}

unsigned int SystemEncrypt_Byte(unsigned int a1, int a2, unsigned int a3)
{
  char v3; // lr
  unsigned int v4; // r8
  unsigned int v5; // r4
  unsigned int v6; // r0
  unsigned int v7; // r10
  unsigned int v8; // r0
  unsigned int v9; // r0
  int v10; // r1
  int v11; // r2
  unsigned int v12; // r0

  v4 = a1;
  v5 = (a2 ^ 0xFFFFFFF8) & a2;
  v6 = (0x9Bu >> (8 - v5)) & (155 << v5) | (0x9Bu >> (8 - v5)) ^ (155 << v5);
  v7 = ~v6 & 0xCA92AFEC | v6 & 0x356D5013;
  v8 = (~(v4 << (8 - v5)) & 0x35944A5C | (v4 << (8 - v5)) & 0xCA6BB5A3) ^ (~(v4 >> v5) & 0x35944A5C | (v4 >> v5) & 0xCA6BB5A3) | ~(~(v4 << (8 - v5)) | ~(v4 >> v5));
  v9 = (~v8 & 0xCA92AFEC | v8 & 0x356D5013) ^ v7;
  v10 = (a3 >> (8 - ((a2 + 1) & 7))) & (a3 << ((a2 + 1) & 7)) | (a3 >> (8 - ((a2 + 1) & 7))) ^ (a3 << ((a2 + 1) & 7));
  v11 = ~(_BYTE)v5 & 7 | 8 * (v5 >> 3);
  v12 = (unsigned __int8)((v3 & ~(_BYTE)v9 | v9 & ~v3) ^ (v3 & ~(_BYTE)v10 | v10 & ~v3));
  return (v12 << (8 - v11)) & (v12 >> v11) | (v12 << (8 - v11)) ^ (v12 >> v11);
}

unsigned int SystemCrc_Pre(unsigned int a1, char a2)
{
  unsigned int v2; // r3
  char v3; // r2
  unsigned int v4; // r0

  v2 = a1;
  v3 = 32 - (a2 & 3);
  v4 = ((0x670F1A9Bu >> (a2 & 3)) & 0xDA877EC4 | ~(0x670F1A9Bu >> (a2 & 3)) & 0x2578813B) ^ ((1729043099 << v3) & 0xDA877EC4 | ~(1729043099 << v3) & 0x2578813B) | ~(~(1729043099 << v3) | ~(0x670F1A9Bu >> (a2 & 3)));
  return v4 & ~((v2 << (a2 & 3)) & (v2 >> v3) | (v2 >> v3) ^ (v2 << (a2 & 3))) | ((v2 << (a2 & 3)) & (v2 >> v3) | (v2 >> v3) ^ (v2 << (a2 & 3))) & ~v4;
}

unsigned int DataEncrypt_Word(unsigned int a1, char a2, unsigned int a3)
{
  char v3; // ST0C_1
  unsigned int v4; // ST10_4
  char v5; // r11
  char v6; // r8
  char v7; // r4
  unsigned int v8; // r1
  unsigned int v9; // r2
  int v10; // r1
  unsigned int v11; // r12
  unsigned int v12; // r1
  unsigned int v13; // r1

  v3 = a2;
  v4 = a3;
  v5 = a2;
  v6 = a2 & 0x1F;
  v7 = 32 - (a2 & 0x1F);
  v8 = (0x430B18ACu >> v7) & (1124800684 << v6) | (0x430B18ACu >> v7) ^ (1124800684 << v6);
  v9 = (~(a1 << v7) & 0xC7BAFAF9 | (a1 << v7) & 0x38450506) ^ (~(a1 >> v6) & 0xC7BAFAF9 | (a1 >> v6) & 0x38450506) | ~(~(a1 << v7) | ~(a1 >> v6));
  v10 = v8 & ~v9 | v9 & ~v8;
  v11 = ~v10 & 0x1818F37A | v10 & 0xE7E70C85;
  ++v5;
  v12 = (~(v4 << (v5 & 0x1F)) & 0x7FF7F9CC | (v4 << (v5 & 0x1F)) & 0x80080633) ^ ((v4 >> (32 - (v5 & 0x1F))) & 0x80080633 | ~(v4 >> (32 - (v5 & 0x1F))) & 0x7FF7F9CC) | ~(~(v4 >> (32 - (v5 & 0x1F))) | ~(v4 << (v5 & 0x1F)));
  v13 = (~v12 & 0x1818F37A | v12 & 0xE7E70C85) ^ v11;
  LOBYTE(v9) = (v6 & 0x37 | (~v3 | 0xE0) & 0xC8) ^ 0xD7;
  return ~(~(v13 << (32 - v9)) | ~(v13 >> v9)) | ((v13 << (32 - v9)) & 0xCD69F34E | ~(v13 << (32 - v9)) & 0x32960CB1) ^ ((v13 >> v9) & 0xCD69F34E | ~(v13 >> v9) & 0x32960CB1);
}

unsigned int DataEncrypt_Byte(unsigned int a1, int a2, unsigned int a3)
{
  unsigned int v3; // ST08_4
  unsigned int v4; // r4
  unsigned int v5; // r0
  unsigned int v6; // ST14_4
  unsigned int v7; // r0
  unsigned int v8; // r10
  char v9; // r1
  unsigned int v10; // r0
  int v11; // r0
  unsigned int v12; // r0
  int v13; // r2

  v3 = a1;
  v4 = (a2 ^ 0xFFFFFFF8) & a2;
  v5 = (0xACu >> (8 - v4)) & (172 << v4) | (0xACu >> (8 - v4)) ^ (172 << v4);
  v6 = ~v5 & 0xB9E37FAB | v5 & 0x461C8054;
  v7 = (~(v3 << (8 - v4)) & 0xB5287CF5 | (v3 << (8 - v4)) & 0x4AD7830A) ^ (~(v3 >> v4) & 0xB5287CF5 | (v3 >> v4) & 0x4AD7830A) | ~(~(v3 << (8 - v4)) | ~(v3 >> v4));
  v8 = (~v7 & 0xB9E37FAB | v7 & 0x461C8054) ^ v6;
  v9 = (a2 + 1) & 7;
  v10 = (~(a3 >> (8 - v9)) & 0xDC0C8F11 | (a3 >> (8 - v9)) & 0x23F370EE) ^ (~(a3 << v9) & 0xDC0C8F11 | (a3 << v9) & 0x23F370EE) | ~(~(a3 >> (8 - v9)) | ~(a3 << v9));
  v11 = v10 & ~v8 | v8 & ~v10;
  v12 = v11 & (v11 ^ 0xFFFFFF00);
  v13 = ~(_BYTE)v4 & 7 | 8 * (v4 >> 3);
  return ~(~(v12 << (8 - v13)) | ~(v12 >> v13)) | ((v12 << (8 - v13)) & 0x6650C5EA | ~(v12 << (8 - v13)) & 0x99AF3A15) ^ ((v12 >> v13) & 0x6650C5EA | ~(v12 >> v13) & 0x99AF3A15);
}

unsigned int DataCrc_Pre(unsigned int a1, char a2)
{
  unsigned int v2; // ST04_4
  char v3; // r0
  signed int v4; // r3
  unsigned int v5; // r5
  unsigned int v6; // r1
  unsigned int v7; // r0

  v2 = a1;
  v3 = (a2 ^ 0xFC) & a2;
  v4 = 1124800684 << (32 - v3);
  v5 = v4 ^ (0x430B18ACu >> v3);
  v6 = (0x430B18ACu >> v3) & v4;
  v7 = ((v2 >> (32 - v3)) & 0x5C19148D | ~(v2 >> (32 - v3)) & 0xA3E6EB72) ^ ((v2 << v3) & 0x5C19148D | ~(v2 << v3) & 0xA3E6EB72) | ~(~(v2 >> (32 - v3)) | ~(v2 << v3));
  return (~v7 & 0x5B6806C5 | v7 & 0xA497F93A) ^ (~(v6 | v5) & 0x5B6806C5 | (v6 | v5) & 0xA497F93A);
}

unsigned int BuildFinderPrintEncrypt_Word(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // ST0C_4
  unsigned int v4; // ST10_4
  char v5; // r9
  char v6; // r2
  unsigned int v7; // r1
  unsigned int v8; // r12
  unsigned int v9; // r1
  unsigned int v10; // r1
  unsigned int v11; // r12
  unsigned int v12; // r1
  int v13; // r2
  unsigned int v14; // r1

  v3 = a2;
  v4 = a3;
  v5 = a2;
  v6 = a2 & 0x1F;
  v7 = (~(939791039 << (a2 & 0x1F)) & 0x2994234F | (939791039 << (a2 & 0x1F)) & 0xD66BDCB0) ^ ((0x380412BFu >> (32 - (a2 & 0x1F))) & 0xD66BDCB0 | ~(0x380412BFu >> (32 - (a2 & 0x1F))) & 0x2994234F) | ~(~(0x380412BFu >> (32 - (a2 & 0x1F))) | ~(939791039 << (a2 & 0x1F)));
  v8 = ~v7 & 0xD37CBFC8 | v7 & 0x2C834037;
  v9 = (~(a1 << (32 - v6)) & 0xD1878AF3 | (a1 << (32 - v6)) & 0x2E78750C) ^ ((a1 >> v6) & 0x2E78750C | ~(a1 >> v6) & 0xD1878AF3) | ~(~(a1 << (32 - v6)) | ~(a1 >> v6));
  v10 = (~v9 & 0xD37CBFC8 | v9 & 0x2C834037) ^ v8;
  ++v5;
  v11 = ~v10 & 0xFE7AEBDC | v10 & 0x1851423;
  v12 = (~(v4 << (v5 & 0x1F)) & 0xB526BC34 | (v4 << (v5 & 0x1F)) & 0x4AD943CB) ^ ((v4 >> (32 - (v5 & 0x1F))) & 0x4AD943CB | ~(v4 >> (32 - (v5 & 0x1F))) & 0xB526BC34) | ~(~(v4 >> (32 - (v5 & 0x1F))) | ~(v4 << (v5 & 0x1F)));
  v13 = ~v3 & 0x1F;
  v14 = (~v12 & 0xFE7AEBDC | v12 & 0x1851423) ^ v11;
  return ~(~(v14 << (32 - v13)) | ~(v14 >> v13)) | ((v14 << (32 - v13)) & 0xA125BEBD | ~(v14 << (32 - v13)) & 0x5EDA4142) ^ ((v14 >> v13) & 0xA125BEBD | ~(v14 >> v13) & 0x5EDA4142);
}

unsigned int BuildFinderPrintEncrypt_Byte(unsigned int a1, char a2, unsigned int a3)
{
  int v3; // r8
  unsigned int v4; // ST10_4
  char v5; // r5
  char v6; // r9
  char v7; // r1
  unsigned int v8; // r2
  int v9; // r0
  unsigned int v10; // r0

  v4 = a3;
  v5 = a2;
  v6 = a2;
  v7 = a2 & 7;
  v8 = (191 << v7) & (0xBFu >> (8 - v7)) | (0xBFu >> (8 - v7)) ^ (191 << v7);
  v9 = (v3 | ~v3) & ~(~(a1 << (8 - v7)) | ~(a1 >> v7)) | (v3 & ~(a1 << (8 - v7)) | (a1 << (8 - v7)) & ~v3) ^ ((a1 >> v7) & ~v3 | v3 & ~(a1 >> v7));
  v10 = (~v9 & 0x44688DBF | v9 & 0xBB977240) ^ (~v8 & 0x44688DBF | v8 & 0xBB977240);
  LOBYTE(v8) = ((v5 + 1) ^ 0xF8) & (v5 + 1);
  LOBYTE(v10) = (~(_BYTE)v10 & 0x6F | v10 & 0x90) ^ (~((v4 >> (8 - v8)) & (v4 << v8) | (v4 >> (8 - v8)) ^ ((_BYTE)v4 << v8)) & 0x6F | ((v4 >> (8 - v8)) & (v4 << v8) | (v4 >> (8 - v8)) ^ ((_BYTE)v4 << v8)) & 0x90);
  return ((unsigned __int8)v10 << (8 - (~v6 & 7))) & ((unsigned __int8)v10 >> (~v6 & 7)) | ((unsigned __int8)v10 << (8 - (~v6 & 7))) ^ ((unsigned __int8)v10 >> (~v6 & 7));
}

unsigned int BuildFinderPrintCrc_Pre(unsigned int a1, int a2)
{
    unsigned int v2; // ST08_4
    unsigned int v3; // r0
    char v4; // r1
    unsigned int v5; // r2

    v2 = a1;
    v3 = (a2 ^ 0xFFFFFFFC) & a2;
    v4 = 32 - v3;
    unsigned int v50 = (0x380412BFu >> v3) & (939791039 << v4) ;
    v5 = v50 | (939791039 << v4) ^ (0x380412BFu >> v3);
    return ((v2 << v3) & (v2 >> v4) | (v2 >> v4) ^ (v2 << v3)) & ~v5 | v5 & ~((v2 << v3) & (v2 >> v4) | (v2 >> v4) ^ (v2 << v3));
}

unsigned int BuildFinderPrintCrc_Pre_old(unsigned int a1, int a2)
{
  unsigned int v2; // ST08_4
  unsigned int v3; // r0
  char v4; // r1
  unsigned int v5; // r2

  v2 = a1;
  v3 = (a2 ^ 0xFFFFFFFC) & a2;
  v4 = 32 - v3;
  v5 = (0x380412BFu >> v3) & (939791039 << v4) | (939791039 << v4) ^ (0x380412BFu >> v3);
  return ((v2 << v3) & (v2 >> v4) | (v2 >> v4) ^ (v2 << v3)) & ~v5 | v5 & ~((v2 << v3) & (v2 >> v4) | (v2 >> v4) ^ (v2 << v3));
}

unsigned int BuildFinderPrintCrc_Pre2(unsigned int a1, unsigned int a2) {
    return ((a1 << (a2 & (a2 ^ 0xFFFFFFFC))) | (a1 >> (-(a2 & (a2 ^ 0xFFFFFFFC)) + 0x20))) ^ ((0x380412BF << (-(a2 & (a2 ^ 0xFFFFFFFC)) + 0x20)) | (0x380412BF >> (a2 & (a2 ^ 0xFFFFFFFC))));
}

unsigned int AllPkgNameMD5Encrypt_Word(unsigned int a1, int a2, unsigned int a3)
{
  int v3; // r8
  int v4; // r9
  int v5; // r10
  unsigned int v6; // ST08_4
  int v7; // r4
  unsigned int v8; // r0
  unsigned int v9; // r1
  unsigned int v10; // r12
  int v11; // r1
  unsigned int v12; // r1
  int v13; // r2
  unsigned int v14; // r1
  int v15; // r0

  v6 = a1;
  v7 = a2;
  v8 = (v7 ^ 0xFFFFFFE0) & v7;
  v9 = (v5 | ~v5) & ~(~(0x890519D2 >> (32 - v8)) | ~(-1996154414 << v8)) | ((-1996154414 << v8) & ~v5 | v5 & ~(-1996154414 << v8)) ^ ((0x890519D2 >> (32 - v8)) & ~v5 | v5 & ~(0x890519D2 >> (32 - v8)));
  v10 = ~v9 & 0x69142601 | v9 & 0x96EBD9FE;
  v11 = (v4 & ~(v6 << (32 - v8)) | (v6 << (32 - v8)) & ~v4) ^ ((v6 >> v8) & ~v4 | v4 & ~(v6 >> v8)) | (v4 | ~v4) & ~(~(v6 << (32 - v8)) | ~(v6 >> v8));
  v12 = (~v11 & 0x69142601 | v11 & 0x96EBD9FE) ^ v10;
  v13 = (a3 >> (32 - ((v7 + 1) & 0x1F))) & (a3 << ((v7 + 1) & 0x1F)) | (a3 >> (32 - ((v7 + 1) & 0x1F))) ^ (a3 << ((v7 + 1) & 0x1F));
  v14 = v13 & ~v12 | v12 & ~v13;
  v15 = ~(_BYTE)v8 & 0x1F | 32 * (v8 >> 5);
  return (v3 | ~v3) & ~(~(v14 << (32 - v15)) | ~(v14 >> v15)) | ((v14 << (32 - v15)) & ~v3 | v3 & ~(v14 << (32 - v15))) ^ ((v14 >> v15) & ~v3 | v3 & ~(v14 >> v15));
}

unsigned int AllPkgNameMD5EncryptCrc_Pre(unsigned int a1, int a2)
{
  unsigned int v2; // r9
  char v3; // r0
  unsigned int v4; // r1
  char v5; // r3
  unsigned int v6; // r2
  unsigned int v7; // r0

  v2 = a1;
  v3 = a2 & 3;
  v4 = 0x890519D2 >> (a2 & 3);
  v5 = 32 - v3;
  v6 = (v4 & 0x588832C1 | ~v4 & 0xA777CD3E) ^ ((-1996154414 << v5) & 0x588832C1 | ~(-1996154414 << v5) & 0xA777CD3E);
  v7 = ((v2 << v3) & 0xDAFED21E | ~(v2 << v3) & 0x25012DE1) ^ ((v2 >> v5) & 0xDAFED21E | ~(v2 >> v5) & 0x25012DE1) | ~(~(v2 >> v5) | ~(v2 << v3));
  return (v6 | ~(~(-1996154414 << v5) | ~v4)) & ~v7 | v7 & ~(v6 | ~(~(-1996154414 << v5) | ~v4));
}

unsigned int AllPkgNameMD5EncryptCrc_Pre2(unsigned int a1, int a2) {
    return (a1 << (a2 & 0x3)) ^ (0x890519D2 << (-(a2 & 0x3) + 0x20));
}

unsigned int ProcSelfMountsCheck(unsigned int a1,unsigned int a2)
{
    unsigned int v2 = a1 ^ (a2 * a1);
    return (0x5E1154A2 ^ v2 & (v2 ^ 0x48))  ^   0x5E1154E2 | ((v2 & (v2 ^ 0x48)) & 0x40);
}

unsigned int ProcSelfMountsCheck_simtest(int a1, int a2)
{
    int v2; // r2

  v2 = a1 & ~(a2 * a1) | a2 * a1 & ~a1;
  return (~(v2 & (v2 ^ 0x48)) & 0x5E1154A2 | v2 & (v2 ^ 0x48) & 0xA1EEAB5D) ^ 0x5E1154E2 | ~(~(v2 & (v2 ^ 0x48)) | 0xFFFFFFBF);
}


unsigned int timeval117(unsigned int a1)
{
  int v1; // r9
  int v2; // r1
  signed int v3; // r2
  unsigned int v4; // r6
  unsigned int v5; // r3

  v2 = 0;
  v3 = -1;
  v4 = 0x1000000;
  do
  {
    if ( ((v2 & ~v1 | v3 & v1) ^ (v1 & 0xFFFFFFEF | 16 * (((unsigned int)~v1 >> 4) & 1)) | (v1 | ~v1) & ~v3 & 0x10) != 24 )
    {
      v5 = ((a1 >> v2) & ((a1 >> v2) ^ 0xFFFFFFFE)) << v2;
      v4 = (~v4 & 0x85ABCEFB | v4 & 0x7A543104) ^ (v5 & 0x7A543104 | ~v5 & 0x85ABCEFB) | ~(~v5 | ~v4);
    }
    ++v2;
    --v3;
  }
  while ( v2 != 32 );
  return v4;
}

unsigned int tag128_obf(int a1, int a2)
{
  unsigned int v2; // r0

  v2 = ~(~((~a1 & 0x8E7686EA | a1 & 0x71897915) ^ (~(a2 * a1) & 0x8E7686EA | a2 * a1 & 0x71897915)) | 0x12452);
  return ~(~v2 | 0xFFFFFBFF) | (v2 & 0xEDA7A372 | ~v2 & 0x12585C8D) ^ 0x1258588D;
}


// ~(~a | ~b) = a & b
// (~a & b) | (a & ~b) = a ^ b

unsigned int tag128_simplefiy(int a1, int a2)
{
//    unsigned int b = 0x12585c8d;

//    unsigned int v2 = ~(~(a1 ^ (a2 * a1)) | 0x12452);
    unsigned int v2 = (a1 ^ (a2 * a1)) & 0xfffedbad;
    
//    return ~ (~v2 | ~0x400) | (v2 ^ 0x400);
//    return  (v2 & 0x400) | (v2 ^ 0x400);
//    return  (v2 & 0x400) | (v2 ^ 0x400);
    return  v2 | 0x400;
}

// final
unsigned int tag128(int a1, int a2)
{
    unsigned int v2 = (a1 ^ (a2 * a1)) & 0xfffedbad;
    return  v2;
}
