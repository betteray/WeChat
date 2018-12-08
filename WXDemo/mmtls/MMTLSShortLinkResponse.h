//
//  MMTLSShortLinkResponse.h
//  WXDemo
//
//  Created by ray on 2018/12/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTLSShortLinkResponse : NSObject

- (instancetype)initWithData:(NSData *)responseData;

- (NSData *)getHashPart;
- (NSData *)getPart1;
- (NSData *)getPart2;
- (NSData *)getPart3;

@end
