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

    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    CdnSnsUploadTask *snsUploadTask = [CdnSnsUploadTask new];
    NSDictionary *dic = [snsUploadTask parseResponseToDic:data];
    LogVerbose(@"%@", dic);
    
//    message CDNUploadMsgImgPrepareRequest {
//    optional  string  clientImgId  = 1;
//    optional  string  fromUserName  = 2;
//    optional  string  toUserName  = 3;
//    required  int32  thumbHeight  = 4;
//    required  int32  thumbWidth  = 5;
//    optional  string  msgSource  = 6;
//    optional  SKBuiltinBuffer_t  clientStat  = 7;
//    optional  int32  scene  = 8;
//    optional  float  longitude  = 9;
//    optional  float  latitude  = 10;
//    optional  string  attachedContent  = 11;
//    optional  string  aeskey  = 16;
//    optional  int32  encryVer  = 17;
//    optional  uint32  crc32  = 18;
//    optional  uint32  msgForwardType  = 19;
//    optional  uint32  source  = 20;
//    optional  string  appid  = 21;
//    optional  string  messageAction  = 22;
//    optional  string  meesageExt  = 23;
//    optional  string  mediaTagName  = 24;

    
    AccountInfo *accountInfo = [DBManager accountInfo];
    CDNUploadMsgImgPrepareRequest *request = [CDNUploadMsgImgPrepareRequest new];
    request.clientImgId = @"rowhongwei56_1576073040";
    request.fromUserName = accountInfo.userName;
    request.toUserName = @"wxid_30uhdskklyci22";
    request.thumbWidth = 100;
    request.thumbHeight = 100;
    request.msgSource = @"";
    request.scene = 0;
//    request.aeskey =
//    request.crc32 =
    request.msgForwardType = 1;
    request.source = 20;
    request.appid = @"";
    request.messageAction = @"";
    request.meesageExt = @"";
    request.mediaTagName = @"";
}

#pragma mark - Auth

- (IBAction)ManualAuth {
    [AuthService manualAuthWithViewController:self userName:self.userNameTextField.text password:self.pwdTextField.text];
}

- (IBAction)clearLogin:(id)sender {
    [DBManager clearCookie];
    [DBManager clearAutoAuthKey];
    [DBManager clearSyncKey];
}

@end

