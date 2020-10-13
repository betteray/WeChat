//
//  EncryptStPairTest.m
//  WeChat
//
//  Created by ray on 2020/9/4.
//  Copyright © 2020 ray. All rights reserved.
//

#import "EncryptStPairTest.h"
#include "EncryptStPair.hpp"
#import "NSData+CRC32.h"

@implementation EncryptStPairTest

+ (void)test {
//    unsigned int byte1_1 = encrypt_asm_tag86(551136); // 传入89 微妙数，得86。
//    unsigned int byte1_1 = encrypt_asm_tag90(551136, 1597229284); // 传入 89, 88, 得 90 。
    
//    unsigned int byte1_1 = PkgHash3EncryptWord(1598862640, 0, 0x38633831);
    
//    unsigned int byte1_1 = EntranceClassLoaderNameEncryptWord(0x5F33B2B1, 0, 0x766C6164);
//    unsigned int byte1_1 = EntranceClassLoaderNameEncryptByte(0xb1, 0, 0x72);
//
//    unsigned int byte1_1 = APKLeadingMD5EncryptWord(0x5F33B2B1, 0, 0x37386339);
//
//    unsigned int byte1_1 = AppInstrumentationClassNameEncryptByte(1597667788, 0, 0x2e6d6f63);// 88 当key，55当明文，得97 //貌似没问题了。

//    unsigned int byte1_1 = AMSBinderClassNameEncryptWord(0x5F33B2B1, 0, 0x72646e61);
//    unsigned int byte1_1 = AMSBinderClassNameEncryptByte(0xB1, 1, 0x79);
    
//    unsigned int byte1_1 = AMSSingletonClassNameEncryptWord(0x5F2E60C1u, 0, 0x44434241u);
//    unsigned int byte1 = AMSSingletonClassNameEncryptByte(0xc1, 0, 0x49);
    
//    unsigned int byte1_1 = ApkSignatureMd5EncryptWord(0x5F33B2B1, 0, 0x38633831);
    
//    unsigned int byte1_1 = SystemFrameworkMD5EncryptWord(0x5f33b2b1, 0, 0x64313464);
//    unsigned int byte1_1 = SystemFrameworkMD5EncryptWord(0x5f33b2b1, 1, 0x39646338);
//
//    unsigned int byte1_1 = SystemFrameworkArmMD5Word(0x5f33b2b1, 0, 0x64313464);
//    unsigned int byte1_1 = SystemFrameworkArmMD5Word(0x5f33b2b1, 1, 0x39646338);
//
//    unsigned int byte1_1 = SystemFrameworkArm64MD5EncryptWord(0x5f33b2b1, 0, 0x64313464);
//    unsigned int byte1_1 = SystemFrameworkArm64MD5EncryptWord(0x5f33b2b1, 1, 0x39646338);
//
//    unsigned int byte1_1 = SystemBinMD5EncryptWord(0x5f33b2b1, 0, 0x64313464);
//    unsigned int byte1_1 = SystemBinMD5EncryptWord(0x5f33b2b1, 1, 0x39646338);
//
//    unsigned int byte1_1 = StorageIDEncryptWord(0x5f33b2b1, 0, 0x7c407c40);
//    unsigned int byte1_1 = StorageIDEncryptWord(1597223601, 0, 0x36393531);
//
//    unsigned int byte1_1 = encrypt_asm_tag117(0xdd599);
//    unsigned int byte1_1 = encrypt_tag117(0xdd599);
    
//    unsigned int byte1_1 = encrypt_word_asm_tag118(0x5f33b2b1, 0, 0x7461642f);
//    unsigned int byte1_1 = encrypt_word_asm_tag118(0x5f33b2b1, 1, 0x70612f61);
//
//    unsigned int byte1_1 = SourceDirEncryptWord(0x5f33b2b1, 0, 0x7461642f);
//    unsigned int byte1_1 = SourceDirEncryptByte(0xb1, 0, 0x61);
//    unsigned int byte1_1 = SourceDirEncryptByte(0xb1, 1, 0x70);
//
//    unsigned int byte1_1 = SourceDir2EncryptWord(0x5f33b2b1, 0, 0x6f72702f);
//    unsigned int byte1_1 = SourceDir2EncryptByte(0xb1, 0, 0x64);
//
//    unsigned int byte1_1 = PkgHash3CrcPre(888000);
//    unsigned int byte1_1 = EntranceClassLoaderNameCrcPre(888440);
//    unsigned int byte1_1 = APKLeadingMD5CrcPre(888440);
//    unsigned int byte1_1 = AppInstrumentationClassNameCrcPre(888440);
//    unsigned int byte1_1 = AMSBinderClassNameCrcPre(257710);
//    unsigned int byte1_1 = AMSSingletonClassNameCrcPre(257710);
//    unsigned int byte1_1 = ApkSignatureMd5CrcPre(888440);
//    unsigned int byte1_1 = SystemFrameworkMD5CrcPre(888440);
//    unsigned int byte1_1 = SystemFrameworkArmMD5CrcPre(888440);
//    unsigned int byte1_1 = SystemFrameworkArm64MD5CrcPre(888440);
//    unsigned int byte1_1 = SystemBinMD5CrcPre(888440);
//    unsigned int byte1_1 = StorageIDCrcPre(257710);
//    unsigned int byte1_1 = SourceDirCrcPre(888440);
//    unsigned int byte1_1 = SourceDir2CrcPre(888440);
//    unsigned int byte1_1 = AMSSingletonClassNameEncryptWord(1598862640, 0, 1919184481);

//    unsigned int byte1_1 = encrypt_tag90(42868, 1599466024);
    
//     unsigned int byte1_1 = StackTraceEncrypt_Word(0x5F867CB8, 0, 0x2e6d6f63);
//    unsigned int byte1_1 = StackTraceEncrypt_Byte(0xB8, 0, 0x61);
//     unsigned int byte1_1 = StackTraceCrc_Pre(0x881fa);

//     unsigned int byte1_1 = ServiceListMd5Encrypt(0x5F867CB8, 0, 0x32353431);
//     unsigned int byte1_1 = ServiceListMd5Crc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemAppMD5Encrypt(0x5F867CB8, 0, 0x35386563);
//     unsigned int byte1_1 = SystemAppMD5Crc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemPrivAppMD5Encrypt(0x5F867CB8, 0, 0x64316566);
//     unsigned int byte1_1 = SystemPrivAppMD5Crc_Pre(0x881fa);

//     unsigned int byte1_1 = VendorAppMD5Encrypt(0x5F867CB8, 0, 0x63626636);
    // unsigned int byte1_1 = VendorAppMD5Encrypt(0x5F867CB8, 1, 0x33393762);
//     unsigned int byte1_1 = VendorAppMD5Crc_Pre(0x881fa);

//     unsigned int byte1_1 = ProductAppMD5Encrypt(0x5F867CB8, 0, 0x30306335);
     unsigned int byte1_1 = ProductAppMD5Crc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemBinLsEncrypt(0x5F867CB8, 0, 0x30306335);
//     unsigned int byte1_1 = SystemBinLsCrc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemFrameworkFrameworkResEncrypt(0x5F867CB8, 0, 0x61383865);
//     unsigned int byte1_1 = SystemFrameworkFrameworkResCrc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemLibLibcPlusPlusEncrypt(0x5F867CB8, 0, 0x33376361);
//     unsigned int byte1_1 = SystemLibLibcPlusPlusCrc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemBinLinkerEncrypt(0x5F867CB8, 0, 0x64636438);
//     unsigned int byte1_1 = SystemBinLinkerCrc_Pre(0x881fa);

//     unsigned int byte1_1 = RootEncrypt_Word(0x5F867CB8, 0, 0x37393531);
//     unsigned int byte1_1 = RootEncrypt_Byte(0xB8, 0, 0x30);
//     unsigned int byte1_1 = RootCrc_Pre(0x881fa);

//     unsigned int byte1_1 = SystemEncrypt_Word(0x5F867CB8, 0, 0x37393531);
//     unsigned int byte1_1 = SystemEncrypt_Byte(0xB8, 0, 0x30);
//     unsigned int byte1_1 = SystemCrc_Pre(0x881fa);

//     unsigned int byte1_1 = DataEncrypt_Word(0x5F867CB8, 0, 0x37393531);
//     unsigned int byte1_1 = DataEncrypt_Byte(0xB8, 0, 0x30);
//     unsigned int byte1_1 = DataCrc_Pre(0x881fa);

//     unsigned int byte1_1 = BuildFinderPrintEncrypt_Word(0x5F867CB8, 0, 0x72646e61);
//     unsigned int byte1_1 = BuildFinderPrintEncrypt_Byte(0xB8, 0, 0x54);
    // unsigned int byte1_1 = BuildFinderPrintCrc_Pre(0x881fa, 0x20);
    
//    unsigned int byte1_1 = ProcSelfMountsCheck(293189, 1601214211);
    char buf[1024] = {0};
    sprintf(buf, "%x", byte1_1);
    NSLog(@"%s", buf);
    
//    NSData *ddd = [@"android.os.BinderProxy" dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *ddd = [@"2751892445d07da7582b3fcaa31184359ed8c99d65" dataUsingEncoding:NSUTF8StringEncoding];
    // 3791711083 + storageid
    NSData *ddd = [@"37917110831593755076.864682156@7182cc1ce823bc61|7bb9decfd60c096098d358b6ca3be9c5@18f75bf9fb7a0f11|15a1e775c4d7903bdc5e538a1d263750" dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t crc32 = [ddd crc32];
}

@end
