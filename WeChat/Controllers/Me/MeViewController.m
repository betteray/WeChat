//
//  SnsTimeLineViewController.m
//  WeChat
//
//  Created by ray on 2018/12/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;

@end

@implementation MeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getprofile];
}

- (void)getprofile
{
    GetProfileRequest *request = [GetProfileRequest new];
    request.userName = @"";
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 302;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/getprofile";
    cgiWrap.responseClass = [GetProfileResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(GetProfileResponse *_Nullable response) {
                          [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:response.userInfoExt.bigHeadImgURL]];
                          
                          self.nickNameLabel.text = response.userInfo.nickName.string;
                          self.signatureLabel.text = response.userInfo.signature;
                      }
                      failure:^(NSError *_Nonnull error){
                          
                      }];
}

@end
