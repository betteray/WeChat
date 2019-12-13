//
//  DownloadVideoService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "DownloadVideoService.h"
#import "FSOpenSSL.h"

#define DATA_SEG_LEN 5000

@implementation DownloadVideoService

+ (void)downloadVideo:(int)msgId startPos:(int)startPos dataTotalLen:(int)dataTotalLen {
    int count = 0;
    if (dataTotalLen - startPos >= DATA_SEG_LEN)
    {
        count = DATA_SEG_LEN;
    }
    else
    {
        count = (int)dataTotalLen - startPos;
    }
    
    DownloadVideoRequest *request = [DownloadVideoRequest new];
    request.msgId = msgId;
    request.startPos = startPos;
    request.networkEnv = 1;
    request.totalLen = count;
    request.mxPackSize = dataTotalLen;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 150;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/downloadvideo";
    cgiWrap.responseClass = [DownloadVideoResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(DownloadVideoResponse *_Nullable response) {
                            LogDebug(@"%@", response);

                            if (startPos + count < dataTotalLen) {
                                [self downloadVideo:msgId startPos:startPos + count dataTotalLen:dataTotalLen];
                            }
        
                            [self saveVideoToDoc:response];
                      }
                      failure:^(NSError *_Nonnull error){}];
    
}

+ (void)saveVideoToDoc:(DownloadVideoResponse *)resp {
    if (resp.baseResponse.ret == 0) {
        NSData *voiceData = resp.data_p.buffer;
        NSString *dirName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent:@"video"];
        NSFileManager *fileNamager = [NSFileManager defaultManager];
        if ([fileNamager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSString *fileName = [dirName stringByAppendingPathComponent:[FSOpenSSL md5StringFromData:voiceData]];
            [voiceData writeToFile:fileName atomically:YES];
        }
    }
}

@end
