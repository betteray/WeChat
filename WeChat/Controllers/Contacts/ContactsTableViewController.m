//
//  ContactsTableViewController.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactsTableViewCell.h"
#import "WCContact.h"

#import "ChatDetailTableViewController.h"

@interface ContactsTableViewController ()

@property (nonatomic, strong) RLMResults *contacts;
@property (nonatomic) RLMNotificationToken *token;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    [self refreshContacts];
    
    __weak typeof(self) weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf refreshContacts];
    }];
}

- (void)refreshContacts
{
    _contacts = [WCContact allObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCContact *contact = [_contacts objectAtIndex:indexPath.row];
    
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell" forIndexPath:indexPath];
    cell.avatarUrl = contact.bigHeadImgUrl;
    cell.nickName = contact.nickName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    WCContact *contact = [_contacts objectAtIndex:indexPath.row];

    ChatDetailTableViewController *chatDetailVC = segue.destinationViewController;
    chatDetailVC.curUser = contact;
}

@end
