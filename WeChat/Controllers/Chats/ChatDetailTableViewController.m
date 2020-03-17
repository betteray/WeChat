//
//  ChatDetailTableViewController.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ChatDetailTableViewController.h"
#import "WCMessage.h"
#import "ChatsDetailTableViewCell.h"
#import "AccountInfo.h"
#import "SendMsgService.h"
#import "MMKeyBoardView.h"
#import "UIView+LoadFromXIB.h"

@interface ChatDetailTableViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MMKeyBoardViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;

@property (nonatomic, strong) RLMResults *messages;
@property (nonatomic) RLMNotificationToken *token;

@end

@implementation ChatDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _curUser.nickName;
    
    _msgTextField.delegate = self;
  
    MMKeyBoardView *keyboardView = [MMKeyBoardView dc_loadFromXIB];
    keyboardView.delegate = self;
    _msgTextField.inputView = keyboardView;
    
    [self refreshChats:YES];

    __weak typeof(self) weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf refreshChats:YES];
    }];
}

- (void)refreshChats:(BOOL)animated
{
    _messages = [WCMessage objectsWhere:@"fromUser = %@ OR toUser = %@", _curUser, _curUser];
    [self.tableView reloadData];
    if ([_messages count] == 0) return;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatsDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsDetailTableViewCell"
                                                                     forIndexPath:indexPath];
    WCMessage *msg = [_messages objectAtIndex:indexPath.row];
    cell.avatarImageUrl = msg.fromUser.smallHeadImgUrl;
    cell.msgContent = msg.content;
        
    return cell;
}

#pragma mark -

- (BOOL)onMMKeyBoardViewSendText:(MMKeyBoardView *)keyboardView {
    [SendMsgService sendTextMsg:self.msgTextField.text toUser:self.curUser];
    self.msgTextField.text = @"";
    return YES;
}

- (BOOL)onMMKeyBoardViewSendVoice:(MMKeyBoardView *)keyboardView {
//    [SendMsgService sendVoiceMsg:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"] toUser:self.curUser]; // ok
    [SendMsgService sendAppMsg:@"" toUser:self.curUser];
    return YES;
}

- (BOOL)onMMKeyBoardViewSendPic:(MMKeyBoardView *)keyboardView {
    [SendMsgService sendImgMsg:[[NSBundle mainBundle] pathForResource:@"pic_1" ofType:@"jpg"] toUser:self.curUser];
    return YES;
}

- (BOOL)onMMKeyBoardViewSendVideo:(MMKeyBoardView *)keyboardView {
    [SendMsgService sendVideoMsg:[[NSBundle mainBundle] pathForResource:@"1106281122" ofType:@"mp4"]
                       imagePath:[[NSBundle mainBundle] pathForResource:@"pic_1" ofType:@"jpg"]
                          toUser:self.curUser
                   imageStartPos:0]; //
    return YES;
}

@end
