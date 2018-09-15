//
//  ViewController.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ViewController.h"
#import "WeChatClient.h"
#import "Mm.pbobjc.h"
#import "Constants.h"
#import "AES.h"
#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "CgiWrap.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (IBAction)getQRCode {
    
    NSData *aesKey = [AES random128BitAESKey];
    BaseRequest *base = [BaseRequest new];
    [base setUin:0];
    [base setScene:0];
    [base setClientVersion:CLIENT_VERSION];
    [base setDeviceType:DEVICE_TYPE];
    [base setSessionKey:aesKey];
    [base setDeviceId:[NSData dataWithHexString:DEVICE_ID]];

    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];
    [request setBase:base];

    sKBuiltinBufferT *buffer = [sKBuiltinBufferT new];
    [buffer setIlen:16];
    [buffer setBuffer:aesKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:nil];
    [request setUserName:nil];
    [request setSoftType:nil];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 502;
    cgiWrap.cmdId = 232;
    cgiWrap.request = request;
    
    [[WeChatClient sharedClient] setAesKey:aesKey];

    [[WeChatClient sharedClient] startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *)response;
        NSLog(@"%@", response);
        self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
