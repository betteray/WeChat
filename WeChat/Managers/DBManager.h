//
//  DBManager.h
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

+ (nullable AccountInfo *)accountInfo;

@end

NS_ASSUME_NONNULL_END
