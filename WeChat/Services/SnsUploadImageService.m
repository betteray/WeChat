//
//  SnsUploadImageService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SnsUploadImageService.h"
#import "FSOpenSSL.h"

#define DATA_SEG_LEN (50000)

@implementation SnsUploadImageService

+ (void)SnsUpload:(NSString *)imagePath starPos:(NSUInteger)startPos {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString *md5 = [FSOpenSSL md5StringFromData:imageData];
    long dataTotalLength = [imageData length];

    int count = 0;
    if (dataTotalLength - startPos > DATA_SEG_LEN)
    {
        count = DATA_SEG_LEN;
    }
    else
    {
        count = (int) (dataTotalLength - startPos);
    }
    
    SnsUploadRequest *request = [SnsUploadRequest new];
    request.clientId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
    request.totalLen = (uint32_t) dataTotalLength;
    request.startPos = (uint32_t) startPos;
    
    NSData *subData = [imageData subdataWithRange:NSMakeRange(startPos, count)];
    SKBuiltinBuffer_t *data_p = [SKBuiltinBuffer_t new];
    data_p.buffer = subData;
    data_p.iLen = (uint32_t)[subData length];
    request.buffer = data_p;
    
    request.type = 2;
    request.md5 = md5;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 0;
    cgiWrap.cgi = 207;
    cgiWrap.request = request;
    cgiWrap.needSetBaseRequest = YES;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/mmsnsupload";
    cgiWrap.responseClass = [SnsUploadResponse class];
    
    [WeChatClient postRequest:cgiWrap
                      success:^(SnsUploadResponse * _Nullable response) {
        LogVerbose(@"%@", response);

        if (startPos + count < dataTotalLength && response.baseResponse.ret == 0) {
            [self SnsUpload:imagePath starPos:startPos + count];
        } else {
            
        }
    }
                      failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
