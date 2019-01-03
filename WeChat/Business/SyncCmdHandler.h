//
//  SyncCmdHandler.h
//  WeChat
//
//  Created by ysh on 2019/1/2.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncCmdHandler : NSObject

+ (void)parseCmdList:(NSArray<CmdItem *> *)cmdList;


@end

NS_ASSUME_NONNULL_END
