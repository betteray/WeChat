//
//  Business.m
//  WeChat
//
//  Created by ysh on 2019/7/10.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SyncService.h"
#import "SyncCmdHandler.h"
#import "SyncKeyCompare.h"
#import "PersonalInfoService.h"
#import "GetCDNDnsService.h"
#import "FSOpenSSL.h"

@implementation SyncService



+ (NSData *)identifyReq2bufWithSyncKey:(NSData *)syncKey
                                   uin:(int)uin
{
    NSData *result = [NSData data];
    
    NSInteger syncKeyLen = [syncKey length];
    NSInteger length = (((uin >> 13) & 524287) | (syncKeyLen << 19)) ^ 1442968193;
    NSInteger length2 = 1442968193 ^ (((syncKeyLen >> 13) & 524287) | (uin << 19));
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length >> 24) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length >> 16) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length >> 8) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length) & 255)]]];
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length2 >> 24) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length2 >> 16) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length2 >> 8) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((length2) & 255)]]];
    
    result = [result addDataAtTail:syncKey];
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((CLIENT_VERSION >> 24) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((CLIENT_VERSION >> 16) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((CLIENT_VERSION >> 8) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((CLIENT_VERSION) & 255)]]];
    
    result = [result addDataAtTail:[@"zh_CN_#H" dataUsingEncoding:NSUTF8StringEncoding]]; // 8 bytes
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", 0]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", 0]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", 0]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", 2]]];
    
    int netType = 1;
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((netType >> 24) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((netType >> 16) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((netType >> 8) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((netType) & 255)]]];
    
    int unknown = 2;
    
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((unknown >> 24) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((unknown >> 16) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((unknown >> 8) & 255)]]];
    result = [result addDataAtTail:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) ((unknown) & 255)]]];
    
    return result;
}


+ (void)newInitWithSyncKeyCur:(NSData *)syncKeyCur syncKeyMax:(NSData *)syncKeyMax {
    NewInitRequest *request = [NewInitRequest new];
    AccountInfo *accountInfo = [DBManager accountInfo];
    request.userName = accountInfo.userName;
    SKBuiltinBuffer_t *currentSynckey = nil;
    SKBuiltinBuffer_t *maxSynckey = nil;
    if (syncKeyCur.length == 0) {
        currentSynckey = [SKBuiltinBuffer_t new];
        currentSynckey.iLen = 0;
        maxSynckey = [SKBuiltinBuffer_t new];
        maxSynckey.iLen = 0;
    } else {
        currentSynckey = [[SKBuiltinBuffer_t alloc] initWithData:syncKeyCur error:nil];
        maxSynckey = [[SKBuiltinBuffer_t alloc] initWithData:syncKeyMax error:nil];
    }
    request.currentSynckey = currentSynckey;
    request.maxSynckey = maxSynckey;
    request.language = [[DeviceManager sharedManager] getCurrentDevice].language;
    
    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 139;
    wrap.cmdId = 27;
    wrap.request = request;
    wrap.cgiPath = @"/cgi-bin/micromsg-bin/newinit";
    wrap.responseClass = [NewInitResponse class];
    
    [WeChatClient startRequest:wrap
                      success:^(NewInitResponse *_Nullable response) {
                          [WeChatClient sharedClient].sync_key_cur = [response.currentSynckey data];
                          [WeChatClient sharedClient].sync_key_max = [response.maxSynckey data];
                          
                          // 存数据到数据库。
                          [DBManager saveSyncKey:[WeChatClient sharedClient].sync_key_cur];
        
                          [SyncCmdHandler parseCmdList:response.cmdListArray];
                          
                          LogVerbose(@"newinit cmd count: %d, continue flag: %d", response.cmdCount, response.continueFlag);
                          if (response.continueFlag) {
                              [self newInitWithSyncKeyCur:[WeChatClient sharedClient].sync_key_cur
                                               syncKeyMax:[WeChatClient sharedClient].sync_key_max];
                          } else {
                              [PersonalInfoService getprofileSuccess:^(id  _Nullable response) {
                                  
                              } failure:^(NSError * _Nonnull error) {
                                  
                              }];
                              [GetCDNDnsService getCDNDns];
                          }
                      }
                      failure:^(NSError *error) {
                          LogError(@"%@", error);
                      }];
}

+ (void)newSync {
    LogDebug(@"Request NewSync With Key: %@", [WeChatClient sharedClient].sync_key_cur);
    NewSyncRequest *req = [NewSyncRequest new];
    
    CmdList *oplog = [CmdList new];
    oplog.count = 0;
    req.oplog = oplog;
    req.selector = 262151;
    req.keyBuf = [[SKBuiltinBuffer_t alloc] initWithData:[WeChatClient sharedClient].sync_key_cur error:nil];
    req.scene = 7;
    req.deviceType = [[NSString alloc] initWithData:[[DeviceManager sharedManager] getCurrentDevice].osType encoding:NSUTF8StringEncoding];
    req.syncMsgDigest = 1;
    
    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 138;
    wrap.cmdId = 121;
    wrap.request = req;
    wrap.needSetBaseRequest = NO;
    wrap.cgiPath = @"/cgi-bin/micromsg-bin/newsync";

    wrap.responseClass = [NewSyncResponse class];
    
    [WeChatClient  startRequest:wrap
                        success:^(NewSyncResponse *_Nullable response) {
                            
                            NSError *error = nil;
                            SKBuiltinBuffer_t *buffer1 = [SKBuiltinBuffer_t parseFromData:[WeChatClient sharedClient].sync_key_cur error:nil];
                            SyncKey *oldSyncKey = [[SyncKey alloc] initWithData:buffer1.buffer error:&error];
                            if (error) {
                                LogError("%@", error);
                            }
                            [WeChatClient sharedClient].sync_key_cur = [response.keyBuf data];
                            SKBuiltinBuffer_t *buffer2 = [SKBuiltinBuffer_t parseFromData:[WeChatClient sharedClient].sync_key_cur error:nil];
                            SyncKey *newSyncKey = [SyncKey parseFromData:buffer2.buffer error:&error];
                            if (error) {
                                LogError("%@", error);
                            }
                            // [SyncKeyCompare compaireOldSyncKey:oldSyncKey newSyncKey:newSyncKey];
                            
                            // 存数据到数据库。
                            [DBManager saveSyncKey:[WeChatClient sharedClient].sync_key_cur];
                            
                            [SyncCmdHandler parseCmdList:response.cmdList.listArray];
        
                            [[WeChatClient sharedClient] syncDone];
                        }
                        failure:^(NSError *error) {
                            LogError(@"new sync resp error: %@", error);
                        }];
}

+ (NSData *)syncDoneReq2Buf {
    NSError *error = nil;
    SKBuiltinBuffer_t *buffer = [SKBuiltinBuffer_t parseFromData:[WeChatClient sharedClient].sync_key_cur error:&error];
    SyncKey *syncKey = [SyncKey parseFromData:buffer.buffer error:&error];
    if (!error && syncKey) {
        NSData *body = [syncKey data];
        // 包头:固定8字节,网络字节序;4字节本地时间与上次newsync时间差(us);4字节protobuf长度
        NSData *header = [NSData dataWithHexString:@"000000ff"];
        NSData *sendData = [header addDataAtTail:[NSData packInt32:(int) ([body length]) flip:YES]];
        sendData = [sendData addDataAtTail:body];
        return sendData;
    }
    
    return nil;
}

@end
