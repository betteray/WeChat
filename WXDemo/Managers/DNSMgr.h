//
//  DNSMgr.h
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSMgr : NSObject

+ (instancetype)sharedMgr;

- (NSString *)getShortLinkUrl;
- (NSString *)getLongLinkUrl;

@end
