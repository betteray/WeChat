//
//  ChatsDetailTableViewCell.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ChatsDetailTableViewCell.h"

@interface ChatsDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation ChatsDetailTableViewCell

- (void)setAvatarImageUrl:(NSString *)avatarImageUrl
{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarImageUrl]];
}

- (void)setMsgContent:(NSString *)msgContent
{
    _msgLabel.text = msgContent;
}

@end
