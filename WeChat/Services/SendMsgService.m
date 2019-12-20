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


+ (void)sendVideoMsg:(NSString * _Nonnull)videoPath
           imagePath:(NSString *)imagePath
              toUser:(WCContact *)toUser
       imageStartPos:(uint32_t)imageStartPos {
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
    long imageTotalLenth = [imageData length];

    // 先传图片封面。
    int count = 0;
    if (imageTotalLenth - imageStartPos > DATA_SEG_LEN)
    {
        count = DATA_SEG_LEN;
    }
    else
    {
        count = (int) imageTotalLenth - imageStartPos;
    }
    
    NSData *subImageData = [imageData subdataWithRange:NSMakeRange(imageStartPos, count)];
    
    UploadVideoRequest *request = [UploadVideoRequest new];
    NSString *clientMsgId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
    request.clientMsgId = clientMsgId;
    request.toUserName = toUser.userName;
    
    AccountInfo *info = [DBManager accountInfo];
    request.fromUserName = info.userName;
    
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = [NSData data];
    data_p.iLen = 0;
    request.videoData = data_p;
    request.videoTotalLen = (uint32_t) [videoData length];

    request.playLength = 4;
    request.videoStartPos = imageStartPos;
    request.funcFlag = 2;
    request.cameraType = 2;
    request.videoFrom = 0;
    request.networkEnv = 1;
    request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
    request.encryVer = 1;

    SKBuiltinBuffer_t *thumbData = [SKBuiltinBuffer_t new];
    thumbData.buffer = subImageData;
    thumbData.iLen = (uint32_t) [subImageData length];
    request.thumbData = thumbData;
    request.thumbTotalLen = (uint32_t) imageTotalLenth;
    request.thumbStartPos = imageStartPos;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 149;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvideo";
    cgiWrap.responseClass = [UploadVideoResponse class];
    
    [WeChatClient postRequest:cgiWrap
                       success:^(UploadVideoResponse * _Nullable response) {

        if (imageStartPos + count < imageTotalLenth) {
            [self sendVideoMsg:videoPath imagePath:imagePath toUser:toUser imageStartPos:imageStartPos + count]; // 一直传封面
        } else {
            [self sendVideoMsg:videoPath imagePath:imagePath toUser:toUser videoStartPos:0 clientMsgId:clientMsgId]; // 传完封面传视频
        }

    }
                       failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

+ (void)sendVideoMsg:(NSString * _Nonnull)videoPath
           imagePath:(NSString *)imagePath
              toUser:(WCContact *)toUser
       videoStartPos:(uint32_t)videoStartPos
         clientMsgId:(NSString *)clientMsgId {
    
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    long videoTotalLenth = [videoData length];

    // 再传视频。
    int count = 0;
    if (videoTotalLenth - videoStartPos > DATA_SEG_LEN)
    {
        count = DATA_SEG_LEN;
    }
    else
    {
        count = (int) videoTotalLenth - videoStartPos;
    }
    
    NSData *subVideoData = [videoData subdataWithRange:NSMakeRange(videoStartPos, count)];
    
    UploadVideoRequest *request = [UploadVideoRequest new];
    request.clientMsgId = clientMsgId;
    request.toUserName = toUser.userName;
    
    AccountInfo *info = [DBManager accountInfo];
    request.fromUserName = info.userName;
    
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = subVideoData;
    data_p.iLen = (uint32_t) subVideoData.length;
    request.videoData = data_p;
    request.videoTotalLen = (uint32_t) [videoData length];

    request.playLength = 4;
    request.videoStartPos = videoStartPos;
    request.funcFlag = 2;
    request.cameraType = 2;
    request.videoFrom = 0;
    request.networkEnv = 1;
    request.reqTime = (uint32_t) [[NSDate date] timeIntervalSince1970];
    request.encryVer = 0;

    // 已经传完了封面
    SKBuiltinBuffer_t *thumbData = [SKBuiltinBuffer_t new];
    thumbData.buffer = [NSData data];
    thumbData.iLen = 0;
    request.thumbData = thumbData;
    request.thumbTotalLen = (uint32_t) [imageData length];
    request.thumbStartPos = (uint32_t) [imageData length];
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 149;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/uploadvideo";
    cgiWrap.responseClass = [UploadVideoResponse class];
    
    [WeChatClient postRequest:cgiWrap
                       success:^(UploadVideoResponse * _Nullable response) {

        if (videoStartPos + count < videoTotalLenth) {
            [self sendVideoMsg:videoPath imagePath:imagePath toUser:toUser videoStartPos:videoStartPos + count clientMsgId:clientMsgId]; // 一直传视频
        } else {
        }
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
    request.voiceLength = 5920; // 10秒
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
