//
//  GetMsgImgService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "GetMsgImgService.h"
#import "FSOpenSSL.h"
#import "FileUtil.h"

#define DATA_SEG_LEN 65536

@implementation GetMsgImgService

+ (void)getMsgImg:(uint32_t)msgId startPos:(int)startPos from:(NSString *)from to:(NSString *)to dataTotalLen:(uint32_t)dataTotalLen original:(BOOL)original{
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
    request.compressType = original ? 1 : 0; // 1高清，0缩略
    
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
                      success:^(GetMsgImgResponse *_Nullable response)
    {
        LogDebug(@"%@", response);
        if (startPos + count < dataTotalLen) {
            [self getMsgImg:msgId startPos:(startPos + count) from:from to:to dataTotalLen:dataTotalLen original:original];
        }
        [self saveImgToDoc:response from:from msgId:(uint32_t)msgId original:original];
    }
                      failure:^(NSError *_Nonnull error){}];
    
}

+ (void)saveImgToDoc:(GetMsgImgResponse *)resp from:(NSString *)from msgId:(uint32_t)msgId original:(BOOL)original {
    if (resp.baseResponse.ret == 0) {
        NSData *picData = resp.data_p.buffer;
        NSString *dirName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                              stringByAppendingPathComponent:from];
        dirName = [dirName stringByAppendingPathComponent:@"img"];
        NSString *filePath = [dirName stringByAppendingPathComponent:[NSString stringWithFormat:@"%d%@.jpg", msgId, original ? @"": @"_thumb"]];
        [FileUtil saveFileWithData:picData withFilePath:filePath];
    }
}

@end
