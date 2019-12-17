//
//  SnsUploadImageService.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SnsUploadImageService.h"
#import "FSOpenSSL.h"

#define DATA_SEG_LEN (65535)

@implementation SnsUploadImageService

+ (void)SnsUpload:(NSString *)imagePath {
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString *md5 = [FSOpenSSL md5StringFromData:imageData];
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
        
        SnsUploadRequest *request = [SnsUploadRequest new];
        request.clientId = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        request.totalLen = (uint32_t) dataTotalLength;
        request.startPos = startPos;

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
        cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/snsupload";
        cgiWrap.responseClass = [SnsUploadResponse class];
        
        [WeChatClient postRequest:cgiWrap
                           success:^(SnsUploadResponse * _Nullable response) {
            LogVerbose(@"%@", response);
        }
                           failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        startPos = startPos + count;
    }
}

@end
