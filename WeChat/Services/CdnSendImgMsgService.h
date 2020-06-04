//
//  CdnSendImgMsgService.h
//  WeChat
//
//  Created by ray on 2020/6/2.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CdnSendImgMsgService : NSObject

+ (void)startSendImg:(NSString *)fromUserName toUserName:(NSString *)toUserName pics:(NSDictionary *)picsDict;

@end

NS_ASSUME_NONNULL_END
