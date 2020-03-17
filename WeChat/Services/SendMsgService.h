//
//  SendMsgService.h
//  WeChat
//
//  Created by ray on 2019/12/17.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendMsgService : NSObject

+ (void)sendTextMsg:(NSString *)msgText toUser:(WCContact *)toUser;
+ (void)sendImgMsg:(NSString * _Nonnull)imagePath toUser:(WCContact *)toUser;
+ (void)sendVideoMsg:(NSString * _Nonnull)videoPath imagePath:(NSString *)imagePath toUser:(WCContact *)toUser imageStartPos:(uint32_t)imageStartPos;
+ (void)sendVoiceMsg:(NSString * _Nonnull)voicePath toUser:(WCContact *)toUser;
+ (void)sendAppMsg:(NSString * _Nonnull)msg toUser:(WCContact *)toUser;

@end

NS_ASSUME_NONNULL_END
