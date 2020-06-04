//
//  UIImage+Resize.m
//  WeChat
//
//  Created by ray on 2020/6/3.
//  Copyright © 2020 ray. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (instancetype)thumbnailWithSize:(CGSize)asize
{
    UIImage *image = self;
    CGSize oldsize = image.size;
    
    UIImage *newimage;
    CGRect rect;
    
    if (asize.width/asize.height > oldsize.width/oldsize.height) {
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = (asize.width - rect.size.width)/2;
        rect.origin.y = 0;
    }
    else {
        rect.size.width = asize.width;
        rect.size.height = asize.width*oldsize.height/oldsize.width;
        rect.origin.x = 0;
        rect.origin.y = (asize.height - rect.size.height)/2;
    }
    
    UIGraphicsBeginImageContext(asize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
    [image drawInRect:rect];
    newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}

- (instancetype)thumbnailWithMidSize {
    CGSize oldsize = self.size;
    return [self thumbnailWithSize:CGSizeMake(oldsize.width * 0.8f, oldsize.height * 0.8f)];
}

- (instancetype)thumbnail {
    CGSize oldsize = self.size;
    return [self thumbnailWithSize:CGSizeMake(oldsize.width * 0.3f, oldsize.height * 0.3f)];
}

@end
