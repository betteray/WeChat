//
//  LongClient.h
//  WeChat
//
//  Created by ray on 2018/12/25.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LongLinkClientDelegate <NSObject>

- (void)onRcvData:(NSData *)longlinkData;

@end

@interface LongLinkClient : NSObject

@property (nonatomic, weak) id<LongLinkClientDelegate> delegate;

- (void)start;
- (void)sendData:(NSData *)sendData;

@end
