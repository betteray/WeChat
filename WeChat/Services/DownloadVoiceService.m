//
//  DownloadVoiceService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "DownloadVoiceService.h"
#import "FileUtil.h"

@implementation DownloadVoiceService

+ (void)getMsgVoice:(uint32_t)msgId clientMsgID:(NSString *)clientMsgId bufid:(uint64_t)bufid length:(uint32_t)length {
    DownloadVoiceRequest *request = [DownloadVoiceRequest new];
    request.length = length;
//    request.clientMsgId = clientMsgId;
    request.msgId = 0;
    request.offset = 0;
    request.newMsgId = msgId;
//    request.masterBufId = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 128;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/downloadvoice";
    cgiWrap.responseClass = [DownloadVoiceResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(DownloadVoiceResponse *_Nullable response) {
                            LogDebug(@"%@", response);
                            [self saveVoiceToDoc:response msgId:msgId];
                      }
                      failure:^(NSError *_Nonnull error){}];
}

+ (void)saveVoiceToDoc:(DownloadVoiceResponse *)resp msgId:(uint32_t)msgId {
    if (resp.baseResponse.ret == 0) {
        NSData *voiceData = resp.data_p.buffer;
        NSString *dirName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent:@"voice"];
        NSString *filePath = [dirName stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", msgId]];
        [FileUtil saveFileWithData:voiceData withFilePath:filePath];
    }
}

@end
