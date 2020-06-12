//
//  CdnGetMsgImgTask.h
//  WeChat
//
//  Created by ray on 2020/6/4.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CdnTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface CdnGetMsgImgTask : CdnTask

@property (nonatomic, copy) NSString *fileid;
@property (nonatomic, copy) NSString *aesKey;

@end

NS_ASSUME_NONNULL_END
