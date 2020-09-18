//
//  LoginViewController.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LoginViewController.h"
#import "AuthHandler.h"
#import "AuthService.h"

// test import
#import "CdnSnsUploadTask.h"
#import "GetkvidkeyStrategyService.h"
#import "WCSafeSDK.h"

#import "CdnSendPictureTask.h"
#import "CheckPack.h"
#import "ZZEncryptService.h"
#import "AES_EVP.h"
#import "CUtility.h"
#import "RiskScanBufReq.h"
#import "EnvBits.h"
#import "NSData+Compression.h"
#import "json2pb.h"
//#import <zlib.h>
#include "defs.h"
#import "Varint128.h"

#import "SoftTypeUitl.h"

#import "EncryptStPairTest.h"

void sub_3570()
{
    char byte_48F004[] = {0x7A, 0x6B, 0x37, 0x14, 0x53, 0x77, 0xAE, 0x25, 0xB0, 0xD1, 0x5E, 0x26, 0x85, 0xD7, 0x5E, 0x9A, 0x8A, 0xD2, 0x35, 0x92, 0x17, 0x48};
    //    char off_47DC00[] = {0x68, 0x41, 0x70, 0x50, 0x59, 0x77, 0x45, 0x63, 0x48, 0x61, 0x74, 0x32, 0x30, 0x6C, 0x6C};
    char *off = "hApPYwEcHat20ll";

    unsigned int v0; // r0
    unsigned int v1; // r3
    int v2; // r2
    unsigned char v3; // r1

    v0 = 0;
    v1 = 0;
    do
    {
        v2 = 14 - v0;
        if ( 14 - v0 >= 0xF )
            abort();
        ++v0;

        char tmp = off[v2]; //off_47DC00
        v3 = byte_48F004[v1] ^ tmp;
        byte_48F004[v1++] = (v3 >> 4) | 16 * v3;
        if ( v0 > 0xE )
            v0 = 0;
    }
    while ( v1 < 0x16 );
    NSLog(@"");
}

@interface LoginViewController ()

@property(weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property(weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if PROTOCOL_FOR_ANDROID
    _versionLabel.text = [NSString stringWithFormat:@"Android %@ (0x%x)", [CUtility StringVersionOf:CLIENT_VERSION], CLIENT_VERSION];
#elif PROTOCOL_FOR_IOS
    _versionLabel.text = [NSString stringWithFormat:@"iOS %@ (0x%x)", [CUtility StringVersionOf:CLIENT_VERSION], CLIENT_VERSION];
#endif

    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    if (device.username.length > 0) {
        self.userNameTextField.text = device.username;
    }
    if (device.password.length > 0) {
        self.pwdTextField.text = device.password;
    }

    sub_3570();
//    
//    [RiskScanBufReq test];
//    
//    int a = [EnvBits GetEnvBits];
//    LogVerbose(@"%d", a);
//    
    for (int i=0; i<0xffffffff; i++) {
        BOOL match = [EnvBits GetEnvBits2:i result:65898401];
        if (match) {
            LogVerbose(@"%d", i);
            break;
        }
    }
    
    [SoftTypeUitl calculateK25];
    [SoftTypeUitl calculateK289];
    
    [EncryptStPairTest test];
}

#pragma mark - Auth

- (IBAction)ManualAuth {
    [AuthService manualAuthWithViewController:self userName:self.userNameTextField.text password:self.pwdTextField.text];
}

- (void)AutoAuth {
    [AuthService autoAuthWithRootViewController:(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController];
}

- (IBAction)clearLogin:(id)sender {
    [DBManager clearCookie];
    [DBManager clearAutoAuthKey];
    [DBManager clearSyncKey];
    
    [self showHUDWithText:@"Clear Suc! ✅"];
}

@end

