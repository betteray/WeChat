//
//  FunctionsViewController.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ChatsTableViewController.h"
#import "ChatsTableViewCell.h"
#import "WCMessage.h"
#import "ChatDetailTableViewController.h"

@interface ChatsTableViewController ()

@property (nonatomic, strong) RLMResults *chats;
@property (nonatomic) RLMNotificationToken *token;

@end

@implementation ChatsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshChats];
    
    __weak typeof(self) weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf refreshChats];
    }];

}

- (void)refreshChats
{
    _chats = [[[WCMessage allObjects] sortedResultsUsingKeyPath:@"createTime" ascending:NO] distinctResultsUsingKeyPaths:@[@"fromUser.userName"]];    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chats count];
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ChatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsTableViewCell" forIndexPath:indexPath];
     
     WCMessage *msg = [_chats objectAtIndex:indexPath.row];
     cell.avatarImageUrl = msg.fromUser.bigHeadImgUrl;
     cell.userName = msg.fromUser.nickName;
     cell.lastMsg = msg.content;
     
     return cell;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    WCMessage *msg = [_chats objectAtIndex:indexPath.row];

    ChatDetailTableViewController *chatDetailVC = segue.destinationViewController;
    chatDetailVC.curUser = msg.fromUser;
}

@end
