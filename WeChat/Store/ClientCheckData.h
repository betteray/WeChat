//
//  ClientCheckData.h
//  WeChat
//
//  Created by ysh on 2018/12/26.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ClientCheckDataID;

@interface ClientCheckData : RLMObject

@property NSString *ID;

@property NSData *data; //used for ios login.

@end
