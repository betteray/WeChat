//
//  UIView+LoadFromXIB.m
//  Bole
//
//  Created by 罗红瑞 on 2017/11/20.
//  Copyright © 2017年 DreamflyCaptial. All rights reserved.
//

#import "UIView+LoadFromXIB.h"

@implementation UIView (LoadFromXIB)

+ (nullable instancetype)dc_loadFromXIB {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:nil
                                        options:nil] lastObject];
}

+ (nullable UINib *)dc_nib {
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:[NSBundle mainBundle]];
}

@end
