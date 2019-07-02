//
//  RAYContactManager.h
//  WeChat
//
//  Created by ysh on 2019/5/23.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RAYContactManager : NSObject

+ (instancetype)sharedManager;

- (void)addContact:(id)contact;

- (id)findContact:(NSString *)account;

@end

NS_ASSUME_NONNULL_END
