//
//  SnsUploadImageService.h
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SnsUploadImageService : NSObject

+ (void)SnsUpload:(NSString *)imagePath starPos:(NSUInteger)startPos;

@end

NS_ASSUME_NONNULL_END
