//
//  SnsTimeLineViewController.m
//  WeChat
//
//  Created by ray on 2018/12/15.
//  Copyright © 2018 ray. All rights reserved.
//

#import "MeViewController.h"
#import "WCContact.h"
#import "PersonalInfoService.h"

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [PersonalInfoService getprofileSuccess:^(GetProfileResponse * _Nullable response) {
        LogDebug(@"%@", response);
       
        [self updateUIWithResp:response];
    } failure:^(NSError * _Nullable error) {
        
    }];
}

- (void)updateUIWithResp:(GetProfileResponse *)response {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:response.userInfoExt.bigHeadImgURL]];

    self.nickNameLabel.text = [NSString stringWithFormat:@"%@-%d",
                               response.userInfo.nickName.string,
                               response.userInfo.sex];
    
    self.signatureLabel.text = response.userInfo.signature;
}

@end
