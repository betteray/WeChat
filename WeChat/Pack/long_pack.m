//
//  long_pack.m
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import "long_pack.h"
#import "LongPackage.h"
#import "LongHeader.h"

#define CMDID_NOOP_REQ 6
#define HEARTBEAT_SEQ 0xFFFFFFFF

#define CMDID_IDENTIFY_REQ 205
#define IDENTIFY_SEQ 0xFFFFFFFE

@implementation long_pack

+ (NSData *)pack:(int)seq cmdId:(int)cmdId shortData:(NSData *)shortData
{
    NSMutableData *longlink_header = [NSMutableData data];
    
    [longlink_header appendData:[NSData packInt32:(int) ([shortData length] + 16) flip:YES]];
    [longlink_header appendData:[NSData dataWithHexString:@"0010"]];
    [longlink_header appendData:[NSData dataWithHexString:@"0001"]];
    [longlink_header appendData:[NSData packInt32:cmdId flip:YES]];
    
    if (cmdId == CMDID_NOOP_REQ)
    {
        [longlink_header appendData:[NSData packInt32:HEARTBEAT_SEQ flip:YES]];
    }
    else if (CMDID_IDENTIFY_REQ == cmdId)
    {
        [longlink_header appendData:[NSData packInt32:IDENTIFY_SEQ flip:YES]];
    }
    else
    {
        [longlink_header appendData:[NSData packInt32:seq flip:YES]];
    }
    
    [longlink_header appendData:shortData];
    return [longlink_header copy];
}

+ (LongPackage *)unpack:(NSData *)recvdRawData
{
    LongPackage *lpkg = [LongPackage new];
    
    if ([recvdRawData length] < 16)
    { // 包头不完整。
        LogError(@"Should Contine Read Data: 包头不完整");
        lpkg.result = UnPack_Continue;
        return lpkg;
    }
    
    LongHeader *header = [[LongHeader alloc] init];
    
    header.bodyLength = [recvdRawData toInt32ofRange:NSMakeRange(0, 4) SwapBigToHost:YES];
    header.headLength = [recvdRawData toInt16ofRange:NSMakeRange(4, 2) SwapBigToHost:NO] >> 8;
    header.clientVersion = [recvdRawData toInt16ofRange:NSMakeRange(6, 2) SwapBigToHost:NO] >> 8;
    header.cmdId = [recvdRawData toInt32ofRange:NSMakeRange(8, 4) SwapBigToHost:YES];
    header.seq = [recvdRawData toInt32ofRange:NSMakeRange(12, 4) SwapBigToHost:YES];
    if (header.bodyLength > [recvdRawData length])
    {
        //包未收完。
        LogError(@"Should Contine Read Data: 包未收完。");
        lpkg.result = UnPack_Continue;
        return lpkg;
    }
    
    lpkg.header = header;
    lpkg.body = [recvdRawData subdataWithRange:NSMakeRange(16, [recvdRawData length] - 16)];
    lpkg.result = UnPack_Success;
    
    return lpkg;
}


@end
