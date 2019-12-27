//
//  UIView+LoadFromXIB.h
//  Bole
//
//  Created by 罗红瑞 on 2017/11/20.
//  Copyright © 2017年 DreamflyCaptial. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LoadFromXIB)

+ (nullable instancetype)dc_loadFromXIB;
+ (nullable UINib *)dc_nib;

@end

NS_ASSUME_NONNULL_END
