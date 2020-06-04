//
//  CdnSendPictureTask.h
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CdnTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface CdnSendPictureTask : CdnTask

@property (nonatomic, strong) NSData *sessionbuf;
@property (nonatomic, copy) NSString *aesKey;
@property (nonatomic, copy) NSString *fileKey;
@property (nonatomic, strong) NSDictionary *pics;
@property (nonatomic, copy) NSString *toUser;

@end

NS_ASSUME_NONNULL_END
