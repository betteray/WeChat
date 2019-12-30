//
//  ReportViewController.m
//  WeChat
//
//  Created by ysh on 2019/7/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "ReportViewController.h"
#import "GetkvidkeyStrategyService.h"

@interface ReportViewController ()

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startReport:(id)sender {
    [GetkvidkeyStrategyService get];
}

@end
