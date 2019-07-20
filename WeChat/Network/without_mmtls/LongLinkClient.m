//
//  LongClient.m
//  WeChat
//
//  Created by ray on 2018/12/25.
//  Copyright © 2018 ray. All rights reserved.
//

#import "LongLinkClient.h"
#import <FastSocket.h>
#import "long_pack.h"

#define CMDID_NOOP_REQ 6

@interface LongLinkClient ()

@property (nonatomic, strong) dispatch_queue_t readSerialQueue;
@property (nonatomic, strong) dispatch_queue_t writeSerialQueue;

@property (nonatomic, strong) FastSocket *client;

@end

@implementation LongLinkClient

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _readSerialQueue = dispatch_queue_create("me.ray.FastSocket.Read", DISPATCH_QUEUE_SERIAL);
        _writeSerialQueue = dispatch_queue_create("me.ray.FastSocket.Write", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)start
{
    FastSocket *client = [[FastSocket alloc] initWithHost:@"163.177.81.141" andPort:@"8080"]; //long.weixin.qq.com 58.247.204.141
    if ([client connect])
    {
        LogDebug(@"FastSocket Connected To Server.");
        _client = client;

        [self heartbeat];

        [self readData];
    }
    else
    {
        LogError(@"FastSocket Can Not Connect.");
    }
}

- (void)heartbeat
{
    NSData *heart = [long_pack pack:-1 cmdId:CMDID_NOOP_REQ shortData:nil];
    [self sendData:heart];
    long sent = [self.client sendBytes:[heart bytes] count:[heart length]];
}

- (void)readData
{
    dispatch_async(_readSerialQueue, ^{
        while (1)
        {
            NSData *dataPackage = [self readLongPackage];
            [self.delegate onRcvData:dataPackage];
        }
    });
}

- (NSData *)readLongPackage
{
    NSMutableData *header = [NSMutableData dataWithLength:16];
    long received = [_client receiveBytes:[header mutableBytes] count:16];
    if (received == 16)
    {
        //LogInfo(@"Read 5 bytes Head.");
    }

    LongHeader *longHeader = [long_pack unpackLongHeder:header];
    NSData *payloadData = [self readPayload:longHeader.bodyLength - 16];
    [header appendData:payloadData];

    return [header copy];
}

- (NSData *)readPayload:(NSInteger)payloadLength
{
    NSMutableData *payload = [NSMutableData dataWithLength:payloadLength];
    long received = [_client receiveBytes:[payload mutableBytes] count:payloadLength];
    if (received == payloadLength)
    {
        return [payload copy];
    }
    else
    {
        LogError(@"Read Payload not match expect.");
        return nil;
    }
}

- (void)sendData:(NSData *)sendData
{
    dispatch_async(_writeSerialQueue, ^{
        long sent = [self.client sendBytes:[sendData bytes] count:[sendData length]];
        if (sent == sendData.length)
        {
            LogDebug(@"FastSocket Send all the Data, Len: %ld", sent);
        }
        else
        {
            LogError(@"FastSocket Send Only %ld Bytes.", sent);
        }
    });
}

@end
