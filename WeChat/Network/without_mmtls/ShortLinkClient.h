//
//  ShortLinkClient.h
//  WeChat
//
//  Created by ray on 2018/12/25.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortLinkClient : NSObject

+ (NSData *)post:(NSData *)data toCgiPath:(NSString *)cgiPath;

@end
