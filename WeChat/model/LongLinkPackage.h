//
//  LongLinkPackage.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LongLinkHeader;

@interface LongLinkPackage : NSObject

@property (nonatomic, strong) LongLinkHeader *header;
@property (nonatomic, strong) NSData *body;

@end
