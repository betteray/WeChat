//
//  ServerHello.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ServerHello.h"

@interface ServerHello()

@property (nonatomic, strong) NSData *serverHelloData;

@end

@implementation ServerHello

- (instancetype)initWithData:(NSData *)serverHelloData {
    self = [super init];
    if (self) {
        _serverHelloData = serverHelloData;
    }
    
    return self;
}

- (NSData *)get1stPartData {
    return [_serverHelloData subdataWithRange:NSMakeRange(0, 1)];
}

@end
