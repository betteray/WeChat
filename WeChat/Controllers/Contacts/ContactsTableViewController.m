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
#import "MMWebViewController.h"

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
    cell.avatarUrl = contact.smallHeadImgUrl;
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


- (IBAction)getA8keyReq:(id)sender
{
    NSData *data = [NSData dataWithHexString:@"10021A040800120022020A002A020A0032020A003A92010A8F0168747470733A2F2F737570706F72742E77656978696E2E71712E636F6D2F6367692D62696E2F6D6D737570706F72742D62696E2F61646463686174726F6F6D6279696E766974653F7469636B65743D4133595A44797A7A3852577931387A7667636E6A4F772533442533442666726F6D3D73696E676C656D657373616765266973617070696E7374616C6C65643D3050015A13777869645F70793270737532716C797666323262006A00700078648A010457494649A00194DDB2F307AA0100B00100"];
    NSError *error = nil;
    GetA8KeyReq *req = [[GetA8KeyReq alloc] initWithData:data error:&error];
    SKBuiltinString_t *str = [SKBuiltinString_t new];
    str.string = @"https://support.weixin.qq.com/cgi-bin/mmsupport-bin/addchatroombyinvite?ticket=A7J4dj8MbCs%2BUvaoRfIGJw%3D%3D";
    req.reqURL = str;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 233;
    cgiWrap.cmdId = 0;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/geta8key";
    cgiWrap.request = req;
    cgiWrap.responseClass = [GetA8KeyResp class];
    cgiWrap.needSetBaseRequest = YES;

    [WeChatClient postRequest:cgiWrap success:^(GetA8KeyResp * _Nullable response) {
        LogVerbose(@"%@", response);


            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:response.fullURL]];
            req.HTTPMethod = @"POST";
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                LogVerbose(@"%@", response);
            }];
            [task resume];
        
//        if (response.baseResponse.ret == 0) {
//            UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
//            MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
//            webViewController.url = [NSURL URLWithString:response.fullURL];
//            [self.navigationController pushViewController:webViewController animated:YES];
//        }

    } failure:^(NSError * _Nonnull error) {
        LogError(@"%@", error);
    }];
}

- (void)enterWeChat
{
    
}

@end
