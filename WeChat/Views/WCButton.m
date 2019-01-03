//
//  WCButton.m
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "WCButton.h"

@implementation WCButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

@end
