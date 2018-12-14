//
//  ServerHello.h
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerHello : NSObject

- (instancetype)initWithData:(NSData *)serverHelloData;

- (NSData *)getHashPart;

- (NSData *)getServerPublicKey;

- (NSData *)getPart1;
- (NSData *)getPart2;
- (NSData *)getPart3;
@end
