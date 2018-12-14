//
//  ShortLinkKey.h
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShortLinkKey : NSObject

@property (nonatomic, strong, readonly) NSData *KEY;
@property (nonatomic, strong, readonly) NSData *IV;

- (instancetype)initWithData:(NSData *)keyData;

@end
