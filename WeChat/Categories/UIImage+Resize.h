//
//  UIImage+Resize.h
//  WeChat
//
//  Created by ray on 2020/6/3.
//  Copyright © 2020 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Resize)

- (instancetype)thumbnailWithSize:(CGSize)asize;
- (instancetype)thumbnailWithMidSize;
- (instancetype)thumbnail;

@end

NS_ASSUME_NONNULL_END
