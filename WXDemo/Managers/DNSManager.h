//
//  DNSManager.h
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSManager : NSObject

+ (instancetype)sharedMgr;

- (NSString *)getShortLinkIp;
- (NSString *)getLongLinkIp;

@end