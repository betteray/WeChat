//
//  MomentsTableViewController.m
//  WeChat
//
//  Created by ray on 2019/1/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MomentsTableViewController.h"
#import "FSOpenSSL.h"
#import "CdnLogic.h"
#import "WCSafeSDK.h"
#import "SnsUploadImageService.h"
#import "SnsPostService.h"

@interface MomentsTableViewController ()

@end

@implementation MomentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sendSnsPostRequest:(id)sender {
//    NSMutableArray *ma = [NSMutableArray array];
//    for (int i = 1; i < 4 ; i++) {
//        NSString *pic = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pic_%d", i] ofType:@"jpg"];
//        [ma addObject:pic];
//    }
//
//    [[CdnLogic sharedInstance] startC2CUpload:ma success:^(NSArray *  _Nullable response) {
//        LogVerbose(@"上传朋友圈图片 response： %@", response);
//        if ([response count]) {
//            [SnsPostService startSendSNSPost:response];
//        }
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
//    NSString *pic = [[NSBundle mainBundle] pathForResource:@"pic_1" ofType:@"jpg"];
//    [SnsUploadImageService SnsUpload:pic starPos:0];
    
    [SnsPostService startSendSNSPost:@[@{@"filekey":@"",
                                         @"fileurl": @"http://mmsns.qpic.cn/mmsns/PiajxSqBRaEJqiaOiaOs1mVlDOpllHDOjgYTQ2ibFukn8a8nOrJ3rmvW7lYytkGdDOicQ/0",
                                         @"thumburl":@"http://mmsns.qpic.cn/mmsns/PiajxSqBRaEJqiaOiaOs1mVlDOpllHDOjgYTQ2ibFukn8a8nOrJ3rmvW7lYytkGdDOicQ/150"}]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
