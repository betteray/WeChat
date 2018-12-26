//
//  ShortLinkWithMMTLS.h
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMTLSShortLinkResponse;

@interface ShortLinkWithMMTLS : NSObject

- (instancetype)initWithDecryptedPart2:(NSData *)decryptedPart2
                      resumptionSecret:(NSData *)resumptionSecret
                              httpData:(NSData *)httpData;
- (NSData *)getSendData;
- (NSData *)receiveData:(MMTLSShortLinkResponse *)response;

@end
