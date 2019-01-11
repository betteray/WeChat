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

@interface ChatDetailTableViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        return NO;
    }
    
    SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
    toUserName.string = _curUser.userName;
    
    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserName;
    mmRequestNew.content = textField.text;
    mmRequestNew.type = 1;
    mmRequestNew.createTime = [[NSDate date] timeIntervalSince1970];
    mmRequestNew.clientMsgId = [[NSDate date] timeIntervalSince1970] + arc4random(); //_clientMsgId++;
    //    mmRequestNew.msgSource = @""; // <msgsource></msgsource>
    
    SendMsgRequestNew *request = [SendMsgRequestNew new];
    
    [request setListArray:[NSMutableArray arrayWithObject:mmRequestNew]];
    request.count = (int32_t)[[NSMutableArray arrayWithObject:mmRequestNew] count];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 237;
    cgiWrap.cgi = 522;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newsendmsg";
    cgiWrap.responseClass = [SendMsgResponseNew class];
    
    [WeChatClient startRequest:cgiWrap
                       success:^(SendMsgResponseNew * _Nullable response) {                           
                           NSPredicate *pre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
                           AccountInfo *info = [[AccountInfo objectsWithPredicate:pre] firstObject];
                           WCContact *slf = [[WCContact objectsWhere:@"userName = %@", info.userName] firstObject];
                           
                           RLMRealm *realm = [RLMRealm defaultRealm];
                           [realm beginWriteTransaction];
                           [WCMessage createOrUpdateInDefaultRealmWithValue:@[@([[response listArray] firstObject].newMsgId),
                                                                              slf,
                                                                              self.curUser,
                                                                              @(1),
                                                                              textField.text,
                                                                              @((NSInteger)[[NSDate date] timeIntervalSince1970])]];
                           [realm commitWriteTransaction];
                           
                           textField.text = nil;
                       }
                       failure:^(NSError *error) {
                           NSLog(@"%@", error);
                       }];
    
    [textField resignFirstResponder];
    
    return YES;
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

@end
