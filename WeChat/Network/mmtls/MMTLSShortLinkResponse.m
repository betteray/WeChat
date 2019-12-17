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
@property (nonatomic, strong) NSMutableArray<NSData *> *dataSegs;
@property (nonatomic, strong) NSData *part3Data;

@end

@implementation MMTLSShortLinkResponse

- (instancetype)initWithData:(NSData *)responseData
{
    self = [super init];
    if (self)
    {
        _responseData = responseData;
        _dataSegs = [NSMutableArray array];
        if (_responseData.length) {
            [self parseData];
        }
    }

    return self;
}

- (void)parseData {
    NSUInteger index = 0;
    
    NSData *headData = [self readHeadAtIndex:&index];
    int headType = [self getDataType:headData];
    if (headType == 0x16) {
        uint16_t pubKeyLen = [self readDataLenAtIndex:&index];
        _hashPart = [self readDataAtIndex:&index dataLen:pubKeyLen];
    }
    
    headData = [self readHeadAtIndex:&index];
    headType = [self getDataType:headData];
    if (headType == 0x16) {
        uint16_t hashPartLen = [self readDataLenAtIndex:&index];
        _part1Data = [self readDataAtIndex:&index dataLen:hashPartLen];
    }
    
    
    while (index < _responseData.length) {
        NSData *headData = [self readHeadAtIndex:&index];
        int headType = [self getDataType:headData];
        switch (headType) {
            case 0x16: // 上边已经处理
            {
                uint16_t hashPartLen = [self readDataLenAtIndex:&index];
                _hashPart = [self readDataAtIndex:&index dataLen:hashPartLen];
            }
                break;
            case 0x17:
            {
                uint16_t dataLen = [self readDataLenAtIndex:&index];
                NSData *dataSeg = [self readDataAtIndex:&index dataLen:dataLen];
                if (dataSeg.length) {
                    [_dataSegs addObject:dataSeg];
                }
            }
                break;
            case 0x15:
            {
                uint16_t dataLen = [self readDataLenAtIndex:&index];
                _part3Data = [self readDataAtIndex:&index dataLen:dataLen];
            }
                break;
            default:
                LogError(@"Unkonw Head Type: %x", headType);
                break;
        }
    }
}

- (int)getDataType:(NSData *)headData {
    Byte *bytes = (Byte *)[headData bytes];
    return bytes[0];
}

- (NSData *)readHeadAtIndex:(NSUInteger *)index {
    // 16（17、15）0xf3 0x01
    NSData *result = [_responseData subdataWithRange:NSMakeRange(*index, 3)]; // 3字节头
    *index = *index + 3;
    return result;
}

- (uint16_t)readDataLenAtIndex:(NSUInteger *)index {
    uint16_t result = [_responseData toInt16ofRange:NSMakeRange(*index, 2) SwapBigToHost:YES]; //2字节长度
    *index = *index + 2;
    return result;
}

- (NSData *)readDataAtIndex:(NSUInteger *)index dataLen:(uint16_t)datalen {
    NSData *result = [_responseData subdataWithRange:NSMakeRange(*index, datalen)]; // datalen 长度
    *index = *index + datalen;
    return result;
}

- (NSData *)getHashPart
{
    return _hashPart;
}

- (NSData *)getPart1
{
    return _part1Data;
}

- (NSMutableArray<NSData *> *)getDataSegs
{
    return _dataSegs;
}

- (NSData *)getPart3
{
    return _part3Data;
}

@end
