//
//  DownloadVoiceService.h
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadVoiceService : NSObject

+ (void)getMsgVoice:(int64_t)newMsgId clientMsgID:(NSString *)clientMsgId bufid:(uint64_t)bufid length:(uint32_t)length;

@end

NS_ASSUME_NONNULL_END
