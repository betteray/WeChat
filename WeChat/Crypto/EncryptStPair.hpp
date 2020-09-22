//
//  EncryptStPair.hpp
//  WeChat
//
//  Created by ray on 2020/9/4.
//  Copyright © 2020 ray. All rights reserved.
//

#ifndef EncryptStPair_hpp
#define EncryptStPair_hpp

#include <stdio.h>
int  encrypt_tag86(unsigned int a1);

unsigned int encrypt_tag90(int usec, int sec);

unsigned int  PkgHash3EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int PkgHash3CrcPre(unsigned int a1);

unsigned int  EntranceClassLoaderNameEncryptWord(unsigned int a1, int a2, unsigned int a3);

int  EntranceClassLoaderNameEncryptByte(unsigned int a1, int a2, unsigned char a3);

unsigned int EntranceClassLoaderNameCrcPre(unsigned int a1);

int  APKLeadingMD5EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int APKLeadingMD5CrcPre(unsigned int a1);

unsigned int  AppInstrumentationClassNameEncryptWord(unsigned int key, char round, unsigned int plain);

unsigned int  AppInstrumentationClassNameEncryptByte(unsigned int key, char round, unsigned int byt);

unsigned int AppInstrumentationClassNameCrcPre(unsigned int a1);

int  AMSBinderClassNameEncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int  AMSBinderClassNameEncryptByte(unsigned int a1, char a2, unsigned char a3);

unsigned int  AMSBinderClassNameCrcPre(unsigned int a1);

int  AMSSingletonClassNameEncryptWord(unsigned int key, unsigned int round, unsigned int plain);

unsigned int  AMSSingletonClassNameEncryptByte(unsigned int a1, int a2, unsigned int a3);

unsigned int AMSSingletonClassNameCrcPre(unsigned int a1);

int  ApkSignatureMd5EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int ApkSignatureMd5CrcPre(unsigned int a1);

int  SystemFrameworkMD5EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int SystemFrameworkMD5CrcPre(unsigned int a1);

int  SystemFrameworkArmMD5Word(unsigned int a1, int a2, unsigned int a3);

unsigned int SystemFrameworkArmMD5CrcPre(unsigned int a1);

int  SystemFrameworkArm64MD5EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int SystemFrameworkArm64MD5CrcPre(unsigned int a1);

int  SystemBinMD5EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int SystemBinMD5CrcPre(unsigned int a1);

int  StorageIDEncryptWord(unsigned int key, int round, unsigned int plain);

unsigned int StorageIDCrcPre(unsigned int a1);

int  encrypt_tag117(unsigned int a1);

unsigned int  SourceDirEncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int  SourceDirEncryptByte(int a1, __int16_t a2, unsigned char a3);

unsigned int SourceDirCrcPre(unsigned int a1);

int  SourceDir2EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int  SourceDir2EncryptByte(unsigned int a1, char a2, unsigned char a3);

unsigned int SourceDir2CrcPre(unsigned int a1);

#endif /* EncryptStPair_hpp */
