//
//  CgiWrap.m
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "CgiWrap.h"

@implementation CgiWrap

- (instancetype)init {
    self = [super init];
    if (self) {
        _needSetBaseRequest = YES;
    }
    
    return self;
}

@end
