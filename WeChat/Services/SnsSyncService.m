//
//  SnsSyncService.m
//  WeChat
//
//  Created by ray on 2019/12/30.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SnsSyncService.h"

@implementation SnsSyncService

+ (void)mmSnsSync {
    SnsSyncRequest *request = [SnsSyncRequest new];
    request.selector = 256;
    request.keyBuf = [[SKBuiltinBuffer_t alloc] initWithData:[WeChatClient sharedClient].sync_key_cur error:nil];
    
    CgiWrap *wrap = [CgiWrap new];
    wrap.cgi = 214;
    wrap.cmdId = 0;
    wrap.request = request;
    wrap.needSetBaseRequest = YES;
    wrap.cgiPath = @"/cgi-bin/micromsg-bin/mmsnssync";
    
    wrap.responseClass = [SnsSyncResponse class];
    
    [WeChatClient postRequest:wrap success:^(SnsSyncResponse * _Nullable response) {
        LogVerbose(@"%@", response);
        
        for(CmdItem *item in response.cmdList.listArray) {
            switch (item.cmdId) {
                case 45:
                {
                    // 不晓得为啥会包含这个，是什么东西，是别人发了新朋友圈你还没看的么。
                    SnsObject *object = [SnsObject parseFromData:item.cmdBuf.buffer error:nil];
                    LogVerbose(@"%@", object);
                }
                    break;
                case 46: {
                    // 根据type类型 判断是收到了评论，点赞，还是删除评论（id对应之前收到评论的id）。
                    SnsActionGroup *group = [SnsActionGroup parseFromData:item.cmdBuf.buffer error:nil];
                    LogVerbose(@"%@", group);
                }
                    break;
                default:
                    break;
            }
        }
        
        // 也要更新sync_key。
        [WeChatClient sharedClient].sync_key_cur = [response.keyBuf data];
        [[WeChatClient sharedClient] syncDone]; // 应该也要sync done一下吧，猜的。

    } failure:^(NSError * _Nonnull error) {
        
    }];
}

@end
