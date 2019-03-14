//
//  NewInitViewController.m
//  WeChat
//
//  Created by ray on 2018/12/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "TestViewController.h"
#import "FSOpenSSL.h"
#import "SyncKeyCompare.h"
#import "Varint128.h"
#include "mmpack.h"
#include "NeedRSAEncodePack.h"
#import "header.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)Test:(id)sender
{

}
- (IBAction)registerr:(id)sender {
    
}

- (IBAction)register:(id)sender
{
    NSData *data = [NSData dataWithHexString:@"8A01B6109D"];
    
    
    NSString *binPath = [[NSBundle mainBundle] pathForResource:@"secmanualauth-type-252" ofType:@"bin"];
    NSData *secManualAuth = [NSData dataWithContentsOfFile:binPath];
    ManualAuthRequest *request = [ManualAuthRequest parseFromData:secManualAuth error:nil];
    
    SyncKey *resp = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12080802 10a2f9d6 9e021208 080310cd f6d69e02 12040804 10001204 08051000 12040807 10001208 080810a3 f8d69e02 12080809 10b0f7d6 9e021204 080a1000 1208080b 10fde6d6 9e021208 080d10f1 dcd59e02 1208080e 10f1dcd5 9e021208 081010f1 dcd59e02 12080811 10f1dcd5 9e021204 08651000 12040866 10001204 08671000 12040868 10001204 08691000 1204086b 10001204 086d1000 1204086f 10001204 08701000 12040872 10001209 08c90110 f3f3cae1 05120508 cb011000 120508cc 01100012 0508cd01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];
    
    SyncKey *req = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12040865 10001208 080210be f9d69e02 12040866 10001208 080d10f1 dcd59e02 120508cc 01100012 08080310 cdf6d69e 02120408 67100012 08080b10 fde6d69e 02120408 6f100012 04080410 00120408 68100012 04080510 00120408 69100012 04080710 00120408 6b100012 08080810 a3f8d69e 02120808 0910b0f7 d69e0212 08081010 f1dcd59e 02120808 1110f1dc d59e0212 04087210 00120808 0e10f1dc d59e0212 04087010 00120408 6d100012 04080a10 00120908 c90110fc 88cce105 120508cd 01100012 0508cb01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];
    
    [SyncKeyCompare compaireOldSyncKey:resp newSyncKey:req];
}
- (IBAction)test:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"st_angler_1" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    
//    WCDevice *mgr = [[DeviceManager sharedManager] getCurrentDevice];
//    AutoBuffer buffer;
//    EncodeRSAPack(&buffer, (__int64)[data bytes], (__int64)[data length], (__int64)[LOGIN_RSA_VER172_KEY_N UTF8String], (__int64)[LOGIN_RSA_VER172_KEY_E UTF8String], (__int64) LOGIN_RSA_VER_172, (const char *)0, (unsigned int)0, 0, (const char *)[mgr.deviceID bytes], 163, CLIENT_VERSION, 0);
//    
//    
//    NSData *result = [NSData dataWithBytesNoCopy:buffer.Ptr() length:buffer.Length() freeWhenDone:0];
//    LogVerbose(@"%@", result);
    [self testNeedRSAPack];
}

#define ARRAY_SIZE(x) sizeof(x)/sizeof((x)[0])

- (void)testNeedRSAPack
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1552397760612-21-36-00-rtkvreport-type-716" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    RealTimeKVReportReq *req = [[RealTimeKVReportReq alloc] initWithData:data error:nil];
    LogVerbose(@"%@", req);
    
    char arr[] = {124, 94, 66, 90, 69, 82, 107, 120, 72, 64, 72, 75, 81};
    int length = ARRAY_SIZE(arr);
    [self decodeStr:arr length:length m:62];
    
    char arr2[] = {85, 81, 72, 86, 83, 94};
    length = ARRAY_SIZE(arr2);
    [self decodeStr:arr2 length:length m:59];
    
    char arr3[] = {99,
        65,
        93,
        69,
        90,
        77,
        5,
        119,
        92,
        85,
        83,
        69,
        76,
        114,
        81,
        83,
        77,
        91,
        77,
        76,
        80,
        95,
        72};
    length = ARRAY_SIZE(arr3);
    [self decodeStr:arr3 length:length m:59];
    
    char arr4[] = {
        124,
        112,
        63,
        93,
        126,
        126,
        119,
        123,
        97,
        125,
        120,
        120,
        51,
        40,
        46,
        121,
        45,
        112,
        47,
        101,
        100,
        121,
        35,
        107,
        118,
        36,
        105,
        115,
        85,
        84,
        21
    };
    length = ARRAY_SIZE(arr4);
    [self decodeStr:arr4 length:length m:34];
    
    LogVerbose(@"%s", arr4);
}

- (void)decodeStr:(char *)str length:(int)length m:(int)m {
    for (int i=0; i<length; i++) {
        str[i] ^= (i+1) ^ m ^ length;
    }
}

@end

