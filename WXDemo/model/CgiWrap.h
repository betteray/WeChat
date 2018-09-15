//
//  CgiWrap.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPBMessage;

@interface CgiWrap : NSObject

@property (nonatomic, strong) GPBMessage *request;
@property (nonatomic, assign) int cmdId;
@property (nonatomic, assign) int cgi;
@property (nonatomic, copy) NSString *cgiName;

@end
