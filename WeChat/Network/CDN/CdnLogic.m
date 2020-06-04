//
//  CdnLogic.m
//  WeChat
//
//  Created by ray on 2019/11/29.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnLogic.h"
#import "CdnSnsUploadTask.h"
#import "CdnSendPictureTask.h"

@interface CdnLogic()

@property (nonatomic, assign) NSUInteger seq;

@end

@implementation CdnLogic

+ (instancetype)sharedInstance {
    static CdnLogic *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CdnLogic alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _seq = 1;
    }
    
    return self;
}

- (void)startC2CUpload:(NSArray<NSString *> *)picPaths
               success:(SuccessBlock)successBlock
               failure:(FailureBlock)failureBlock {
    
    NSMutableArray *ma = [NSMutableArray array];
    for (NSString *path in picPaths) {
        CdnSnsUploadTask *task = [[CdnSnsUploadTask alloc] initWithSeq: _seq++];
        task.picPath = path;
        [task startCdnRequestSuccess:^(id  _Nullable response) {
            [ma addObject:response];
            if ([ma count] == [picPaths count]) {
                successBlock(ma);
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

- (void)startSSUpload:(NSDictionary *)pics
           sessionbuf:(NSData *)sessionbuf
               aesKey:(NSString *)aesKey
              fileKey:(NSString *)fileKey
               toUser:(NSString *)toUser
              success:(SuccessBlock)successBlock
              failure:(FailureBlock)failureBlock {
    CdnSendPictureTask *task = [[CdnSendPictureTask alloc] initWithSeq:_seq++];
    task.sessionbuf = sessionbuf;
    task.aesKey = aesKey;
    task.fileKey = fileKey;
    task.pics = pics;
    task.toUser = toUser;

    [task startCdnRequestSuccess:successBlock failure:failureBlock];
}

@end
