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

@interface LoginViewController ()

@property(weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property(weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if PROTOCOL_FOR_ANDROID
    _versionLabel.text = [NSString stringWithFormat:@"Android (0x%x)", CLIENT_VERSION];
#elif PROTOCOL_FOR_IOS
    _versionLabel.text = [NSString stringWithFormat:@"iOS (0x%x)", CLIENT_VERSION];
#endif

    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    if (device.username.length > 0) {
        self.userNameTextField.text = device.username;
    }
    if (device.password.length > 0) {
        self.pwdTextField.text = device.password;
    }
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

