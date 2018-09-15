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
#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "CgiWrap.h"

#define TICK_INTERVAL 5

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (IBAction)getQRCode {
    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    sKBuiltinBufferT *buffer = [sKBuiltinBufferT new];
    [buffer setIlen:16];
    [buffer setBuffer:[WeChatClient sharedClient].aesKey];
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
    cgiWrap.responseClass = [GetLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        NSLog(@"%@", response);
        GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *)response;
        
        self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
        self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tick:(NSTimer *)timer {
    [self updateUI];
    
    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];
    
    sKBuiltinBufferT *buffer = [sKBuiltinBufferT new];
    [buffer setIlen:16];
    [buffer setBuffer:[WeChatClient sharedClient].aesKey];
    [request setRandomEncryKey:buffer];

    request.uuid = ((GetLoginQRCodeResponse *)[timer userInfo]).uuid;
    request.timeStamp = [[NSDate date] timeIntervalSince1970];
    request.opcode = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 503;
    cgiWrap.cmdId = 233;
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        NSLog(@"%@", response);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)updateUI {
    NSInteger remainTime = [_qrcodeTimerLabel.text integerValue] - TICK_INTERVAL;
    if (remainTime <= 0) {
        self.qrcodeTimerLabel.text = @"二维码已过期";
    } else {
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", (int)remainTime];
    }
}

@end
