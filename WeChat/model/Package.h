//
//  Package.h
//  WXDemo
//
//  Created by ray on 2018/9/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@interface Package : NSObject

@property (nonatomic, strong) Header *header;
@property (nonatomic, strong) NSData *body;

@end
