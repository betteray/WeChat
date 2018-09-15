//
//  LongLinkHeader.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongLinkHeader : NSObject

@property (nonatomic, assign) uint32_t bodyLength;
@property (nonatomic, assign) uint32_t headLength;
@property (nonatomic, assign) uint16_t clientVersion;   //协议版本号
@property (nonatomic, assign) uint32_t cmdId;
@property (nonatomic, assign) uint32_t seq;             //封包序号

@end
