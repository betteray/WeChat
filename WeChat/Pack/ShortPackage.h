//
//  Package.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortHeader.h"

@interface ShortPackage : NSObject

@property (nonatomic, strong) ShortHeader *header;
@property (nonatomic, strong) NSData *body;

@property (nonatomic, assign) uint32_t uin;
@property (nonatomic, strong) NSData *cookie;

@end
