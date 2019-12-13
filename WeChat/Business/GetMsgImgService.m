//
//  GetMsgImgService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "GetMsgImgService.h"
#import "FSOpenSSL.h"

#define DATA_SEG_LEN 65535

@implementation GetMsgImgService

+ (void)getMsgImg:(uint32_t)msgId from:(NSString *)from to:(NSString *)to dataTotalLen:(uint32_t)dataTotalLen {
    uint32_t startPos = 0;
    while (startPos < dataTotalLen) {
        
        int count = 0;
        if (dataTotalLen - startPos >= DATA_SEG_LEN)
        {
            count = DATA_SEG_LEN;
        }
        else
        {
            count = (int)dataTotalLen - startPos;
        }
        
        GetMsgImgRequest *request = [GetMsgImgRequest new];
        request.msgId = msgId;
        request.startPos = startPos;
        request.dataLen = count;
        request.totalLen = dataTotalLen;
        request.compressType = 0; // 1高清，0缩略
        
        SKBuiltinString_t *fromUserName = [SKBuiltinString_t new];
        fromUserName.string = from;
        request.fromUserName = fromUserName;
        
        SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
        toUserName.string = to;
        request.toUserName = toUserName;
        
        CgiWrap *cgiWrap = [CgiWrap new];
        cgiWrap.cgi = 109;
        cgiWrap.request = request;
        cgiWrap.needSetBaseRequest = YES;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/getmsgimg";
        cgiWrap.responseClass = [GetMsgImgResponse class];
        
        [WeChatClient postRequest:cgiWrap
                          success:^(GetMsgImgResponse *_Nullable response) {
                                LogDebug(@"%@", response);
                                [self saveImgToDoc:response from:from];
                          }
                          failure:^(NSError *_Nonnull error){}];
        
        startPos += count;
    }
}

+ (void)saveImgToDoc:(GetMsgImgResponse *)resp from:(NSString *)from {
    if (resp.baseResponse.ret == 0) {
        NSData *picData = resp.data_p.buffer;
        NSString *dirName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent:from];
        NSFileManager *fileNamager = [NSFileManager defaultManager];
        if ([fileNamager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSString *fileName = [dirName stringByAppendingPathComponent:[FSOpenSSL md5StringFromData:picData]];
            [picData writeToFile:fileName atomically:YES];
        }
    }
}

@end
