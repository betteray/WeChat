//
//  GetCDNDnsService.h
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetCDNDnsService : NSObject

+ (void)getCDNDns;

+ (GetCDNDnsResponse *)getCDNDnsResponseFromCache;

@end

NS_ASSUME_NONNULL_END
