//
//  Task.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CgiWrap;

@interface Task : NSObject

@property (nonatomic, strong) id sucBlock;
@property (nonatomic, strong) id failBlock;
@property (nonatomic, strong) CgiWrap* cgiWrap;

@end
