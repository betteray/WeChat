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

@interface ChatDetailTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) RLMResults *messages;
@property (nonatomic) RLMNotificationToken *token;

@end

@implementation ChatDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _curUser.nickName;
    
    [self refreshChats];
    
    __weak typeof(self) weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf refreshChats];
    }];
}

- (void)refreshChats
{
    _messages = [WCMessage objectsWhere:@"fromUser = %@", _curUser];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

- (void)SendMsg
{
    SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
    toUserName.string = @"rowhongwei";
    
    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserName;
    mmRequestNew.content = @"hello";
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
                       success:^(id _Nullable response) {
                           LogVerbose(@"%@", response);
                       }
                       failure:^(NSError *error) {
                           NSLog(@"%@", error);
                       }];
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
    cell.avatarImageUrl = msg.fromUser.bigHeadImgUrl;
    cell.msgContent = msg.content;
        
    return cell;
}

@end
