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
#import "NSData+PackUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECDHUtil.h"

#define TICK_INTERVAL 1.5

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;

@property (nonatomic, strong) NSData *nofityKey;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:@"http://wx.qlogo.cn/mmhead/ver_1/BbicZbKzbDbI6ZkYJzcBsKssqAmmVialdvCj7gNib6e155RaiaDdgW6hDuqxH6dkx386DFdDxp9AjuTferkE48267yib0odQNev96sLsxJm4croY/0"]];;
}

- (IBAction)getQRCode {
    NSLog(@"扫描成功");
    [self.qrcodeCheckTimer invalidate];
    self.qrcodeCheckTimer = nil;
    
    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    sKBuiltinBufferT *buffer = [sKBuiltinBufferT new];
    [buffer setIlen:16];
    [buffer setBuffer:[WeChatClient sharedClient].clientAesKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:0];
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
        
        if (resp) {
            self.nofityKey = resp.notifyKey.buffer;
            self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
            self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
            self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tick:(NSTimer *)timer {
    [self updateUI];
    
    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];
    
    sKBuiltinBufferT *buffer = [sKBuiltinBufferT new];
    [buffer setIlen:16];
    [buffer setBuffer:[WeChatClient sharedClient].clientAesKey];
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
        CheckLoginQRCodeResponse *resp = (CheckLoginQRCodeResponse *)response;
        if (resp.base.code == 0) {
            NSData *notifyProtobufData = [[resp.notifyPkg.notifyData buffer] aesDecryptWithKey:self.nofityKey];
            NotifyMsg *msg = [NotifyMsg parseFromData:notifyProtobufData error:nil];
            if (![msg.avatar isEqualToString:@""]) {
                NSLog(@"扫描成功: %@", msg);
                self.qrcodeTimerLabel.text = msg.nickName;
                [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:msg.avatar]];
            }
            
            if (![msg.wxnewpass isEqualToString:@""]) {//ManualAuth
                [self.qrcodeCheckTimer invalidate];
                self.qrcodeCheckTimer = nil;
                
                int nid = 713;
                char  priKey[2048];
                char  pubKey[2048];
                
                int priLen = 0;
                int pubLen = 0;
                //    BOOL ret = GenEcdh(nid, priKey, sizeof(priKey), pubKey, sizeof(pubKey));
                
                BOOL ret = [ECDHUtil GenEcdh:nid szPriKey:priKey pLenPri:&priLen szPubKey:pubKey pLenPub:&pubLen];
                NSData *priData = [[NSData alloc] initWithBytes:priKey length:priLen];
                NSData *pubData = [[NSData alloc] initWithBytes:pubKey length:pubLen];
                
                NSLog(@"pridata: %@, pubdata: %@", priData, pubData);
            }
            
            if (msg.state == 0 || msg.state == 1) {
                NSLog(@"继续检查确认登陆。");
            }
        }
        
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

- (IBAction)test {
    int nid = 713;
    char  priKey[2048];
    char  pubKey[2048];
    
    int priLen = 0;
    int pubLen = 0;
//    BOOL ret = GenEcdh(nid, priKey, sizeof(priKey), pubKey, sizeof(pubKey));

    BOOL ret = [ECDHUtil GenEcdh:nid szPriKey:priKey pLenPri:&priLen szPubKey:pubKey pLenPub:&pubLen];
    NSData *priData = [[NSData alloc] initWithBytes:priKey length:priLen];
    NSData *pubData = [[NSData alloc] initWithBytes:pubKey length:pubLen];
    
    NSLog(@"pridata: %@, pubdata: %@", priData, pubData);
}

@end
