//
//  LongLinkMMTLS.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LongLinkClientWithMMTLSDelegate <NSObject>

- (void)onLongLinkHandShakeFinishedWithPSK:(NSData *)pskData
                          resumptionSecret:(NSData *)resumptionSecret;

- (void)onRcvData:(NSData *)plainData;

@end

@interface LongLinkClientWithMMTLS : NSObject

@property (nonatomic, weak) id<LongLinkClientWithMMTLSDelegate> delegate;

- (void)start;
- (void)restart;

- (void)sendData:(NSData *)sendData;

@end
