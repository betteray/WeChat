//
//  AutoAuthKeyStore.h
//  WeChat
//
//  Created by ray on 2018/12/29.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AutoAuthKeyStoreID;

@interface AutoAuthKeyStore : RLMObject

@property NSString *ID;

@property NSData *data; //used for ios login.

@end
