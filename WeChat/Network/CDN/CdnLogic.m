//
//  CdnLogic.m
//  WeChat
//
//  Created by ray on 2019/11/29.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnLogic.h"
#import "CdnTask.h"

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
        CdnTask *task = [[CdnTask alloc] initWithSeq: _seq++];
        [task startC2CUpload:path
                     success:^(NSDictionary *  _Nullable response) {
            [ma addObject:response];
            if ([ma count] == [picPaths count]) {
                successBlock(ma);
            }
        }
                     failure:^(NSError * _Nonnull error) {
        }];
    }
}

@end
