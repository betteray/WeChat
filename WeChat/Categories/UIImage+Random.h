//
//  UIImage+Random.h
//  WeChat
//
//  Created by ray on 2020/6/4.
//  Copyright © 2020 ray. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Random)

+ (instancetype)randomImageWithSideLength:(CGFloat) sideLength inset:(CGFloat) inset;

@end

NS_ASSUME_NONNULL_END
