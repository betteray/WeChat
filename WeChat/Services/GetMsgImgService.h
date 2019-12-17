//
//  GetMsgImgService.h
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetMsgImgService : NSObject

+ (void)getMsgImg:(uint32_t)msgId startPos:(int)startPos from:(NSString *)from to:(NSString *)to dataTotalLen:(uint32_t)dataTotalLen original:(BOOL)original;

@end

NS_ASSUME_NONNULL_END
