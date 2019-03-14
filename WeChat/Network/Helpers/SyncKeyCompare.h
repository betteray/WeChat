//
//  SyncKeyCompare.h
//  WeChat
//
//  Created by ysh on 2019/1/8.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncKeyCompare : NSObject

+ (void)compaireOldSyncKey:(SyncKey *)old newSyncKey:(SyncKey *)newkey;

@end

NS_ASSUME_NONNULL_END
