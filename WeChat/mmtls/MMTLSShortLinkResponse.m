//
//  MMTLSShortLinkResponse.m
//  WXDemo
//
//  Created by ray on 2018/12/5.
//  Copyright © 2018 ray. All rights reserved.
//

#import "MMTLSShortLinkResponse.h"

@interface MMTLSShortLinkResponse ()

@property (nonatomic, strong) NSData *responseData;

@property (nonatomic, strong) NSData *hashPart;
@property (nonatomic, strong) NSData *part1Data;
@property (nonatomic, strong) NSData *part2Data;
@property (nonatomic, strong) NSData *part3Data;

@end

@implementation MMTLSShortLinkResponse

- (instancetype)initWithData:(NSData *)responseData
{
    self = [super init];
    if (self)
    {
        _responseData = responseData;

        int index = 3;
        int16_t pubKeyLen = [responseData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES]; //2字节长度

        index += 2;
        _hashPart = [responseData subdataWithRange:NSMakeRange(index, pubKeyLen)];

        index = index + pubKeyLen + 3;
        int16_t part1Len = [responseData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];

        index += 2;
        _part1Data = [responseData subdataWithRange:NSMakeRange(index, part1Len)];

        index = index + part1Len + 3;
        int16_t part2Len = [responseData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];

        index += 2;
        _part2Data = [responseData subdataWithRange:NSMakeRange(index, part2Len)];

        index = index + part2Len + 3;
        int16_t part3Len = [responseData toInt16ofRange:NSMakeRange(index, 2) SwapBigToHost:YES];

        index += 2;
        _part3Data = [responseData subdataWithRange:NSMakeRange(index, part3Len)];
    }

    return self;
}

- (NSData *)getHashPart
{
    return _hashPart;
}

- (NSData *)getPart1
{
    return _part1Data;
}

- (NSData *)getPart2
{
    return _part2Data;
}

- (NSData *)getPart3
{
    return _part3Data;
}

@end
