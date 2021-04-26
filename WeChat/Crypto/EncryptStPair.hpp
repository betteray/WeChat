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
#include <stdint.h>
#include "defs.h"

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
unsigned int StorageIDEncryptByte(unsigned int a1, int a2, unsigned __int8 a3);
unsigned int StorageIDCrcPre(unsigned int usec, int len);

int  encrypt_tag117(unsigned int a1);

unsigned int  SourceDirEncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int  SourceDirEncryptByte(int a1, __int16_t a2, unsigned char a3);

unsigned int SourceDirCrcPre(unsigned int a1);

int  SourceDir2EncryptWord(unsigned int a1, int a2, unsigned int a3);

unsigned int  SourceDir2EncryptByte(unsigned int a1, char a2, unsigned char a3);

unsigned int SourceDir2CrcPre(unsigned int a1);

unsigned int StackTraceEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int StackTraceEncrypt_Byte(unsigned int a1, int a2, unsigned __int8 a3);
unsigned int StackTraceCrc_Pre(unsigned int a1);

unsigned int  ServiceListMd5Encrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int ServiceListMd5Crc_Pre(unsigned int a1);

unsigned int SystemAppMD5Encrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemAppMD5Crc_Pre(unsigned int a1);

unsigned int SystemPrivAppMD5Encrypt(unsigned int a1, char a2, unsigned int a3);
unsigned int SystemPrivAppMD5Crc_Pre(unsigned int a1);

unsigned int VendorAppMD5Encrypt(unsigned int a1, char a2, unsigned int a3);
unsigned int VendorAppMD5Crc_Pre(unsigned int a1);

unsigned int ProductAppMD5Encrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int ProductAppMD5Crc_Pre(unsigned int a1);

unsigned int SystemBinLsEncrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemBinLsCrc_Pre(int usec, int len);

unsigned int SystemFrameworkFrameworkResEncrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemFrameworkFrameworkResCrc_Pre(unsigned int a1);

unsigned int SystemLibLibcPlusPlusEncrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemLibLibcPlusPlusCrc_Pre(unsigned int a1);

unsigned int SystemBinLinkerEncrypt(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemBinLinkerCrc_Pre(int a1);

unsigned int RootEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int RootEncrypt_Byte(unsigned int a1, int a2, unsigned int a3);
unsigned int RootCrc_Pre(unsigned int key, char len);

unsigned int SystemEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemEncrypt_Byte(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemCrc_Pre(unsigned int key, char len);

unsigned int DataEncrypt_Word(unsigned int a1, char a2, unsigned int a3);
unsigned int DataEncrypt_Byte(unsigned int a1, int a2, unsigned int a3);
unsigned int DataCrc_Pre(unsigned int key, char len);

unsigned int BuildFinderPrintEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int BuildFinderPrintEncrypt_Byte(unsigned int a1, char a2, unsigned int a3);
unsigned int BuildFinderPrintCrc_Pre(unsigned int key, int len);
unsigned int BuildFinderPrintCrc_Pre2(unsigned int a1, unsigned int a2);

unsigned int AllPkgNameMD5Encrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int AllPkgNameMD5EncryptCrc_Pre(unsigned int usec, int len);
unsigned int AllPkgNameMD5EncryptCrc_Pre2(unsigned int a1, int a2);

unsigned int BuildDisplayIdEncrypt_Word(unsigned int key, int round, unsigned int plain);
unsigned int BuildDisplayIdEncrypt_Byte(unsigned int key, char round, unsigned __int8 plain);
unsigned int BuildDisplayIdEncrypt_Pre(unsigned int key, int len);

unsigned int BuildFlavorEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int BuildFlavorEncrypt_Byte(unsigned int a1, int a2, unsigned __int8 a3);
unsigned int BuildFlavorEncrypt_Pre(unsigned int a1, char a2);

unsigned int SystemLibLibandroidRuntimeEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemLibLibandroidRuntimeEncrypt_Crc(unsigned int a1);

unsigned int SystemLibLibcameraserviceEncrypt_Word(unsigned int a1, int a2, unsigned int a3);
unsigned int SystemLibLibcameraservice_Crc(unsigned int a1);



// 需单独调用获取gettimeofday一次，当前时间。
unsigned int ProcSelfMountsCheck(unsigned int usec,unsigned int sec);

unsigned int timeval117(unsigned int a1);

// 需单独调用获取gettimeofday一次，当前时间。
unsigned int tag128(int time_usec, int time_sec);

// 需单独调用获取gettimeofday一次，当前时间。
unsigned int timeval133(int time_sec, int time_usec);

#endif /* EncryptStPair_hpp */
