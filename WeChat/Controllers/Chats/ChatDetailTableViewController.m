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

#define DATA_SEG_LEN 50000

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

- (void)sendTextMsg:(NSString * _Nonnull)msgText {
    SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
    toUserName.string = _curUser.userName;
    
    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserName;
    mmRequestNew.content = msgText;
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
        uint64_t newMsgId = [[response listArray] firstObject].newMsgId;
        [DBManager saveMsg:newMsgId withUser:self.curUser msgText:msgText];
    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}


- (void)sendImgMsg:(NSString * _Nonnull)imagePath {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    int startPos = 0;
    long dataTotalLength = [imageData length];

    while (startPos < dataTotalLength) {
        int count = 0;
        if (dataTotalLength - startPos > DATA_SEG_LEN)
        {
            count = DATA_SEG_LEN;
        }
        else
        {
            count = (int) dataTotalLength - startPos;
        }
        
        UploadMsgImgRequest *request = [UploadMsgImgRequest new];
        SKBuiltinString_t *clientImgId = [SKBuiltinString_t new];
        clientImgId.string = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        request.clientImgId = clientImgId;
        
        SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
        toUserName.string = _curUser.userName;
        request.toUserName = toUserName;
        
        AccountInfo *info = [DBManager accountInfo];
        SKBuiltinString_t *fromUserName = [SKBuiltinString_t new];
        fromUserName.string = info.userName;
        request.fromUserName = fromUserName;
        
        NSData *subData = [imageData subdataWithRange:NSMakeRange(startPos, count)];
        SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
        data_p.buffer = subData;
        data_p.iLen = (uint32_t)[subData length];
        request.data_p = data_p;
        
        request.dataLen = (uint32_t) [subData length];
        request.totalLen = (uint32_t) dataTotalLength;
        request.startPos = startPos;
        request.msgType = 3;
        request.meesageExt = @"png";
        request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
        request.encryVer = 0;
        
        CgiWrap *cgiWrap = [CgiWrap new];
        cgiWrap.cmdId = 0;
        cgiWrap.cgi = 110;
        cgiWrap.request = request;
        cgiWrap.needSetBaseRequest = YES;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadmsgimg";
        cgiWrap.responseClass = [UploadMsgImgResponse class];
        
        [WeChatClient postRequest:cgiWrap
                           success:^(UploadMsgImgResponse * _Nullable response) {
            LogVerbose(@"%@", response);
        }
                           failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        startPos = startPos + count;
    }
}

- (void)sendVideoMsg:(NSString * _Nonnull)imagePath {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    int startPos = 0;
    long dataTotalLength = [imageData length];

    while (startPos < dataTotalLength) {
        int count = 0;
        if (dataTotalLength - startPos > DATA_SEG_LEN)
        {
            count = DATA_SEG_LEN;
        }
        else
        {
            count = (int) dataTotalLength - startPos;
        }
        
        UploadVideoRequest *request = [UploadVideoRequest new];
        request.clientMsgId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        request.toUserName = _curUser.userName;
        
        AccountInfo *info = [DBManager accountInfo];
        request.fromUserName = info.userName;
        
        SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
        data_p.buffer = [NSData data];
        data_p.iLen = 0;
        request.videoData = data_p;
        
        request.videoFrom = 0;
        request.playLength = 0;
        request.videoTotalLen = 0;
        request.videoStartPos = 0;
        request.encryVer = 0;
        request.networkEnv = 1;
        request.funcFlag = 2;
        request.cameraType = 2;
        request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
        
        NSData *subData = [imageData subdataWithRange:NSMakeRange(startPos, count)];
        SKBuiltinBuffer_t *thumbData = [SKBuiltinBuffer_t new];
        thumbData.buffer = subData;
        thumbData.iLen = (uint32_t) [subData length];
        request.thumbData = thumbData;
        request.thumbTotalLen = (uint32_t) [imageData length];
        request.thumbStartPos = startPos;
        
        CgiWrap *cgiWrap = [CgiWrap new];
        cgiWrap.cmdId = 0;
        cgiWrap.cgi = 149;
        cgiWrap.request = request;
        cgiWrap.needSetBaseRequest = YES;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvideo";
        cgiWrap.responseClass = [UploadVideoResponse class];
        
        [WeChatClient postRequest:cgiWrap
                           success:^(UploadVideoResponse * _Nullable response) {
            LogVerbose(@"%@", response);
        }
                           failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        startPos = startPos + count;
    }
}


//enum VoiceFormat
//{
//    MM_VOICE_FORMAT_AMR = 0,
//    MM_VOICE_FORMAT_MP3 = 2,
//    MM_VOICE_FORMAT_SILK = 4,
//    MM_VOICE_FORMAT_SPEEX = 1,
//    MM_VOICE_FORMAT_UNKNOWN = -1,
//    MM_VOICE_FORMAT_WAVE = 3
//}

- (void)sendVoiceMsg:(NSString * _Nonnull)voicePath {
    NSData *voiceData = [NSData dataWithContentsOfFile:voicePath]; // 需把正常的amr文件的头去掉再发 2321414D 520A3CDE ｜ #!AMR <.
    
    UploadVoiceRequest *request = [UploadVoiceRequest new];
    request.clientMsgId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
    request.toUserName = _curUser.userName;
    
    AccountInfo *info = [DBManager accountInfo];
    request.fromUserName = info.userName;
    
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = voiceData;
    data_p.iLen = (uint32_t)[voiceData length];
    request.data_p = data_p;
    
//    request.voiceFormat = 0; // amr
    request.voiceLength = 100; // 10秒
    request.length = (uint32_t) [voiceData length]; //字节长度
    request.offset = 0;
    request.endFlag = 1;
    request.msgSource = @"";
    request.msgId = (uint32_t) [[NSDate date] timeIntervalSince1970];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 127;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvoice";
    cgiWrap.responseClass = [UploadVoiceResponse class];
    
    [WeChatClient postRequest:cgiWrap
                       success:^(UploadVoiceResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)test:(id)sender {
//    [self sendImgMsg:[[NSBundle mainBundle] pathForResource:@"1576139358368" ofType:@"jpg"]]; // ok
    [self sendVideoMsg:[[NSBundle mainBundle] pathForResource:@"1576139358368" ofType:@"jpg"]]; //
//    [self sendVoiceMsg:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"amr"]]; // ok
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        return NO;
    }
    
    [self sendImgMsg:textField.text];
    
    textField.text = nil;

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
