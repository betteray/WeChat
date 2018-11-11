//
//  ServerHello.m
//  WXDemo
//
//  Created by ray on 2018/11/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ServerHello.h"
#import "NSData+Util.h"

@interface ServerHello()

@property (nonatomic, strong) NSData *serverHelloData;

@property (nonatomic, strong) NSData *hashPart;
@property (nonatomic, strong) NSData *part1Data;
@property (nonatomic, strong) NSData *part2Data;
@property (nonatomic, strong) NSData *part3Data;

@end

@implementation ServerHello

- (instancetype)initWithData:(NSData *)serverHelloData {
    self = [super init];
    if (self) {
        _serverHelloData = serverHelloData;
        
        DLog(@"Server Hello", _serverHelloData);
        
        int index = 3;
        int16_t pubKeyLen = [serverHelloData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES] ;//2字节长度
        
        index += 2;
        _hashPart = [serverHelloData subdataWithRange:NSMakeRange(index, pubKeyLen)];
        
        DLog(@"Server PubKey", _hashPart);

        index = index + pubKeyLen + 3;
        int16_t part1Len = [serverHelloData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];
        
        index += 2;
        _part1Data = [serverHelloData subdataWithRange:NSMakeRange(index, part1Len)];
        
        DLog(@"Part1", _part1Data);
        
        index = index + part1Len + 3;
        int16_t part2Len = [serverHelloData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];

        index += 2;
        _part2Data = [serverHelloData subdataWithRange:NSMakeRange(index, part2Len)];

        DLog(@"Part2", _part2Data);

        index = index + part2Len + 3;
        int16_t part3Len = [serverHelloData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];
        
        index += 2;
        _part3Data = [serverHelloData subdataWithRange:NSMakeRange(index, part3Len)];
        
        DLog(@"Part3", _part3Data);
    }
    
    return self;
}

- (NSData *)getServerPublicKey {
    return [_hashPart subdataWithRange:NSMakeRange([_hashPart length]-0x41, 0x41)];
}

- (NSData *)getHashPart {
    return _hashPart;
}

- (NSData *)getPart1 {
    return _part1Data;
}

- (NSData *)getPart2 {
    return _part2Data;
}

- (NSData *)getPart3 {
    return _part3Data;
}

@end
