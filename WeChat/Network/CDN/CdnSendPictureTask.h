//
//  CdnSendPictureTask.h
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CdnSendPictureTask : NSObject

- (void)packBody: (NSString *)picPath;

@end

NS_ASSUME_NONNULL_END
