//
//  ClientHello.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientHello : NSObject

- (NSData *)CreateClientHello;

- (NSData *)getHashPart;

- (NSData *)getLocal1stPrikey;

@end
