//
//  KeyPair.h
//  WXDemo
//
//  Created by ray on 2018/11/10.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyPair : NSObject

- (instancetype)initWithData:(NSData *)keyPairData;

@property (nonatomic, strong, readonly) NSData *readKEY;
@property (nonatomic, strong, readonly) NSData *readIV;

@property (nonatomic, strong, readonly) NSData *writeKEY;
@property (nonatomic, strong, readonly) NSData *writeIV;

@end
