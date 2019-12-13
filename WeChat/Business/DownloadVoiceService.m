//
//  DownloadVoiceService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "DownloadVoiceService.h"
#import "FSOpenSSL.h"

@implementation DownloadVoiceService

+ (void)getMsgVoice:(uint32_t)msgId clientMsgID:(NSString *)clientMsgId length:(uint32_t)length {
    DownloadVoiceRequest *request = [DownloadVoiceRequest new];
    request.length = length;
    request.clientMsgId = clientMsgId;
    request.msgId = msgId;
    request.newMsgId = msgId;
    request.offset = 0;
    request.masterBufId = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 128;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/downloadvoice";
    cgiWrap.responseClass = [DownloadVoiceResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(DownloadVoiceResponse *_Nullable response) {
                            LogDebug(@"%@", response);
                            [self saveVoiceToDoc:response];
                      }
                      failure:^(NSError *_Nonnull error){}];
}

+ (void)saveVoiceToDoc:(DownloadVoiceResponse *)resp {
    if (resp.baseResponse.ret == 0) {
        NSData *voiceData = resp.data_p.buffer;
        NSString *dirName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent:@"voice"];
        NSFileManager *fileNamager = [NSFileManager defaultManager];
        if ([fileNamager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSString *fileName = [dirName stringByAppendingPathComponent:[FSOpenSSL md5StringFromData:voiceData]];
            [voiceData writeToFile:fileName atomically:YES];
        }
    }
}

@end
