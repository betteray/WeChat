//
//  LongLinkMMTLS.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LongLinkClientDelegate <NSObject>

- (void)onRecivceLongLinkPlainData:(NSData *)plainData;

@end

@interface LongLinkClient : NSObject

@property (nonatomic, readonly, strong) NSData *shortLinkPSKData;
@property (nonatomic, readonly, strong) NSData *resumptionSecret;

@property (nonatomic, weak) id<LongLinkClientDelegate> delegate;

- (void)start;
- (void)mmtlsEnCryptAndSend:(NSData *)sendData;

@end
