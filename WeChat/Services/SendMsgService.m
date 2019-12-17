//
//  SendMsgService.m
//  WeChat
//
//  Created by ray on 2019/12/17.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SendMsgService.h"

#define DATA_SEG_LEN 50000

@implementation SendMsgService

+ (void)sendTextMsg:(NSString * _Nonnull)msgText toUser:(WCContact *)toUser {
    SKBuiltinString_t *toUserNameB = [SKBuiltinString_t new];
    toUserNameB.string = toUser.userName;
    
    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserNameB;
    mmRequestNew.content = msgText;
    mmRequestNew.type = 1;
    mmRequestNew.createTime = [[NSDate date] timeIntervalSince1970];
    mmRequestNew.clientMsgId = [[NSDate date] timeIntervalSince1970] + arc4random(); //_clientMsgId++;
    //    mmRequestNew.msgSource = @""; // <msgsource></msgsource>
    
    SendMsgRequestNew *request = [SendMsgRequestNew new];
    
    [request setListArray:[NSMutableArray arrayWithObject:mmRequestNew]];
    request.count = (int32_t)[[NSMutableArray arrayWithObject:mmRequestNew] count];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 237;
    cgiWrap.cgi = 522;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = NO;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/newsendmsg";
    cgiWrap.responseClass = [SendMsgResponseNew class];
    
    [WeChatClient startRequest:cgiWrap
                       success:^(SendMsgResponseNew * _Nullable response) {
        uint64_t newMsgId = [[response listArray] firstObject].newMsgId;
        [DBManager saveMsg:newMsgId withUser:toUser msgText:msgText];
    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}


+ (void)sendImgMsg:(NSString * _Nonnull)imagePath toUser:(WCContact *)toUser {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    int startPos = 0;
    long dataTotalLength = [imageData length];

    while (startPos < dataTotalLength) {
        int count = 0;
        if (dataTotalLength - startPos > DATA_SEG_LEN)
        {
            count = DATA_SEG_LEN;
        }
        else
        {
            count = (int) dataTotalLength - startPos;
        }
        
        UploadMsgImgRequest *request = [UploadMsgImgRequest new];
        SKBuiltinString_t *clientImgId = [SKBuiltinString_t new];
        clientImgId.string = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        request.clientImgId = clientImgId;
        
        SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
        toUserName.string = toUser.userName;
        request.toUserName = toUserName;
        
        AccountInfo *info = [DBManager accountInfo];
        SKBuiltinString_t *fromUserName = [SKBuiltinString_t new];
        fromUserName.string = info.userName;
        request.fromUserName = fromUserName;
        
        NSData *subData = [imageData subdataWithRange:NSMakeRange(startPos, count)];
        SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
        data_p.buffer = subData;
        data_p.iLen = (uint32_t)[subData length];
        request.data_p = data_p;
        
        request.dataLen = (uint32_t) [subData length];
        request.totalLen = (uint32_t) dataTotalLength;
        request.startPos = startPos;
        request.msgType = 3;
        request.meesageExt = @"png";
        request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
        request.encryVer = 0;
        
        CgiWrap *cgiWrap = [CgiWrap new];
        cgiWrap.cmdId = 0;
        cgiWrap.cgi = 110;
        cgiWrap.request = request;
        cgiWrap.needSetBaseRequest = YES;
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadmsgimg";
        cgiWrap.responseClass = [UploadMsgImgResponse class];
        
        [WeChatClient postRequest:cgiWrap
                           success:^(UploadMsgImgResponse * _Nullable response) {
            LogVerbose(@"%@", response);
        }
                           failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        startPos = startPos + count;
    }
}


+ (void)sendVideoMsg:(NSString * _Nonnull)videoPath toUser:(WCContact *)toUser {
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
//    int startPos = 0;
//    long dataTotalLength = [videoData length];

    UploadVideoRequest *request = [UploadVideoRequest new];
    request.clientMsgId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
    request.toUserName = toUser.userName;
    
    AccountInfo *info = [DBManager accountInfo];
    request.fromUserName = info.userName;
    
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = videoData;
    data_p.iLen = (uint32_t) [videoData length];
    request.videoData = data_p;
    
    request.videoFrom = 0;
    request.playLength = 4;
    request.videoTotalLen = (uint32_t) [videoData length];
    request.videoStartPos = 0;
    request.encryVer = 1;
    request.networkEnv = 1;
    request.funcFlag = 2;
    request.cameraType = 2;
    request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
    
//    NSData *subData = [videoData subdataWithRange:NSMakeRange(startPos, count)];
//    SKBuiltinBuffer_t *thumbData = [SKBuiltinBuffer_t new];
//    thumbData.buffer = subData;
//    thumbData.iLen = (uint32_t) [subData length];
//    request.thumbData = thumbData;
//    request.thumbTotalLen = (uint32_t) [videoData length];
    request.thumbStartPos = (uint32_t) [videoData length];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 149;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvideo";
    cgiWrap.responseClass = [UploadVideoResponse class];
    
    [WeChatClient postRequest:cgiWrap
                       success:^(UploadVideoResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//enum VoiceFormat
//{
//    MM_VOICE_FORMAT_AMR = 0,
//    MM_VOICE_FORMAT_MP3 = 2,
//    MM_VOICE_FORMAT_SILK = 4,
//    MM_VOICE_FORMAT_SPEEX = 1,
//    MM_VOICE_FORMAT_UNKNOWN = -1,
//    MM_VOICE_FORMAT_WAVE = 3
//}

+ (void)sendVoiceMsg:(NSString * _Nonnull)voicePath toUser:(WCContact *)toUser {
    NSData *voiceData = [NSData dataWithContentsOfFile:voicePath]; // 需把正常的amr文件的头去掉再发 2321414D 520A3CDE ｜ #!AMR <.
    
    UploadVoiceRequest *request = [UploadVoiceRequest new];
    request.clientMsgId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
    request.toUserName = toUser.userName;
    
    AccountInfo *info = [DBManager accountInfo];
    request.fromUserName = info.userName;
    
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = voiceData;
    data_p.iLen = (uint32_t)[voiceData length];
    request.data_p = data_p;
    
//    request.voiceFormat = 0; // amr
    request.voiceLength = 100; // 10秒
    request.length = (uint32_t) [voiceData length]; //字节长度
    request.offset = 0;
    request.endFlag = 1;
    request.msgSource = @"";
    request.msgId = (uint32_t) [[NSDate date] timeIntervalSince1970];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 127;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvoice";
    cgiWrap.responseClass = [UploadVoiceResponse class];
    
    [WeChatClient postRequest:cgiWrap
                       success:^(UploadVoiceResponse * _Nullable response) {
        LogVerbose(@"%@", response);
    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
