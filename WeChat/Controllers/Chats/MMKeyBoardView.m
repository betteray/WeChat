//
//  MMKeyBoardView.m
//  WeChat
//
//  Created by ray on 2019/12/25.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MMKeyBoardView.h"

NS_ENUM(NSUInteger, MMKeyBoardViewType) {
    MMKeyBoardViewType_SendText = 0,
    MMKeyBoardViewType_SendVoice,
    MMKeyBoardViewType_SendPic,
    MMKeyBoardViewType_SendVideo
};

@implementation MMKeyBoardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onClick:(UIButton *)sender {
    if (!self.delegate) {
        return;
    }
    switch (sender.tag) {
        case MMKeyBoardViewType_SendText:
        {
            if ([self.delegate respondsToSelector:@selector(onMMKeyBoardViewSendText:)]) {
                [self.delegate onMMKeyBoardViewSendText:self];
            }
        }
            break;
            
        case MMKeyBoardViewType_SendVoice:
        {
            if ([self.delegate respondsToSelector:@selector(onMMKeyBoardViewSendVoice:)]) {
                [self.delegate onMMKeyBoardViewSendVoice:self];
            }
        }
            break;
        case MMKeyBoardViewType_SendPic:
        {
            if ([self.delegate respondsToSelector:@selector(onMMKeyBoardViewSendPic:)]) {
                [self.delegate onMMKeyBoardViewSendPic:self];
            }
        }
            break;
        case MMKeyBoardViewType_SendVideo:
        {
            if ([self.delegate respondsToSelector:@selector(onMMKeyBoardViewSendVideo:)]) {
                [self.delegate onMMKeyBoardViewSendVideo:self];
            }
        }
            break;
        default:
            break;
    }
}

@end
