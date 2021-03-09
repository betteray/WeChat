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
#import "CalRqtAlg.h"
#import "ZZEncryptService.h"
#import "CdnGetMsgImgTask.h"

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


//    [RiskScanBufReq test];
//    
//    int a = [EnvBits GetEnvBits];
//    LogVerbose(@"%d", a);
//    for (int i=0; i<0xffffffff; i++) {
//        BOOL match = [EnvBits GetEnvBits2:i result:61424493];
//        if (match) {
//            LogVerbose(@"%d", i);
//            break;
//        }
//    }
    

//    [SoftTypeUitl calculateK25];
//    [SoftTypeUitl calculateK289];
//
//    [EncryptStPairTest test];
//
//    [CheckPack check];
//    NSData *data = [Varint128 dataWithUInt64:18446744073576444666];
//    int rqt = [CalRqtAlg calRqtMD5String:@"c43cb292295d2a41d170157e66af6aaf" cmd:1 uin:1];

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

