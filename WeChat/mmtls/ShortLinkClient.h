//
//  ShortLink.h
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortLinkClient : NSObject

- (instancetype)initWithDecryptedPart2:(NSData *)decryptedPart2 resumptionSecret:(NSData *)resumptionSecret;

+ (NSData *)mmPost:(NSData *)mmtlsData
          withHost:(NSString *)headerHost;

+ (NSData *)getPayloadDataWithData:(NSData *)shortlinkData
                           cgiPath:(NSString *)cgiPath
                              host:(NSString *)host;

@end
