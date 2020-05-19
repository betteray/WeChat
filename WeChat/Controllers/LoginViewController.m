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

//    self.userNameTextField.text = @"dathsp06";
//    self.pwdTextField.text = @"kqrjs496";

//    CdnSendPictureTask *task = [CdnSendPictureTask new];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    [task packBody:path];
}
 

#pragma mark - Auth

- (IBAction)ManualAuth {
    [AuthService manualAuthWithViewController:self userName:self.userNameTextField.text password:self.pwdTextField.text];
}

- (IBAction)clearLogin:(id)sender {
    [DBManager clearCookie];
    [DBManager clearAutoAuthKey];
    [DBManager clearSyncKey];
    
    [self showHUDWithText:@"Clear Suc! ✅"];
}

@end

