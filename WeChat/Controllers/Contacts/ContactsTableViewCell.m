//
//  ContactsTableViewCell.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ContactsTableViewCell.h"

@interface ContactsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end

@implementation ContactsTableViewCell

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]];
}

- (void)setNickName:(NSString *)nickName
{
    _nickNameLabel.text = nickName;
}

@end
