//
//  MMKeyBoardView.h
//  WeChat
//
//  Created by ray on 2019/12/25.
//  Copyright © 2019 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMKeyBoardView;

@protocol MMKeyBoardViewDelegate <NSObject>

@optional
- (BOOL)onMMKeyBoardViewSendText:(MMKeyBoardView *)keyboardView;
- (BOOL)onMMKeyBoardViewSendVoice:(MMKeyBoardView *)keyboardView;
- (BOOL)onMMKeyBoardViewSendPic:(MMKeyBoardView *)keyboardView;
- (BOOL)onMMKeyBoardViewSendVideo:(MMKeyBoardView *)keyboardView;

@end

@interface MMKeyBoardView : UIView
@property (nonatomic, weak) id<MMKeyBoardViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
