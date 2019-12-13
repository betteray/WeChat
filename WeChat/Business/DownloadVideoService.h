//
//  DownloadVideoService.h
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadVideoService : NSObject

+ (void)downloadVideo:(int)msgId startPos:(int)startPos dataTotalLen:(int)dataTotalLen;

@end

NS_ASSUME_NONNULL_END
