//
//  OplogService.m
//  WeChat
//
//  Created by ray on 2019/12/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "OplogService.h"

@implementation OplogService

+ (void)oplogRequestWithCmdId:(uint32_t)cmdId message:(GPBMessage *)message {
    NSData *cmdBuffer = [message data];
    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t new];
    buffer.iLen = (int32_t) [cmdBuffer length];
    buffer.buffer = cmdBuffer;
    
    CmdItem *item = [CmdItem new];
    item.cmdId = cmdId;
    item.cmdBuf = buffer;
    
    CmdList *cmdList = [CmdList new];
    cmdList.count = 1;
    cmdList.listArray = [@[item] mutableCopy];
    
    OplogRequest *req = [[OplogRequest alloc] init];
    req.oplog = cmdList;

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 681;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/oplog";
    cgiWrap.request = req;
    cgiWrap.responseClass = [OplogResponse class];
    cgiWrap.needSetBaseRequest = NO;
    
    [WeChatClient postRequest:cgiWrap success:^(OplogResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
