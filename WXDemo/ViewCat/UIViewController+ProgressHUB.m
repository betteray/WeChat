//
//  UIViewController+ProgressHUB.m
//  WXDemo
//
//  Created by ray on 2018/11/28.
//  Copyright © 2018 ray. All rights reserved.
//

#import "UIViewController+ProgressHUB.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation UIViewController (ProgressHUB)

- (void) showHUDWithText: (NSString *) hintText {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hintText;
    
    [hud hideAnimated:YES afterDelay:2.5f];
}

@end
