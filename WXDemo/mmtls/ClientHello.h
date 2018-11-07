//
//  ClientHello.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientHello : NSObject

- (void)setPubKey1:(NSData *)pubKey1;

- (void)setPubKey2:(NSData *)pubKey2;

- (NSData *)CreateClientHello;

- (NSData *)clientRandom;

@end
