//
//  ChatsTableViewCell.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ChatsTableViewCell.h"

@interface ChatsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMsgLabel;

@end

@implementation ChatsTableViewCell

- (void)setAvatarImageUrl:(NSString *)avatarImageUrl
{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarImageUrl]];
}

- (void)setUserName:(NSString *)userName
{
    _userNameLabel.text = userName;
}

- (void)setLastMsg:(NSString *)lastMsg
{
    _lastMsgLabel.text = lastMsg;
}

@end
