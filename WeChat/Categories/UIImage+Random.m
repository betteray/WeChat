//
//  UIImage+Random.m
//  WeChat
//
//  Created by ray on 2020/6/4.
//  Copyright © 2020 ray. All rights reserved.
//

#import "UIImage+Random.h"

@implementation UIImage (Random)

+ (instancetype)randomImageWithSideLength:(CGFloat) sideLength inset:(CGFloat) inset {
    UIGraphicsBeginImageContext(CGSizeMake(sideLength, sideLength));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw in saturated background
    CGRect bounds = CGRectMake(0.0f, 0.0f, sideLength, sideLength);
    CGContextAddRect(context, bounds);
    [[UIColor whiteColor] set];
    CGContextFillPath(context);
    CGContextAddRect(context, bounds);
    [[[UIColor redColor] colorWithAlphaComponent:0.5f] set];
    CGContextFillPath(context);
    
    // Draw in brighter foreground
    CGContextAddEllipseInRect(context, CGRectInset(bounds, inset, inset));
    [[UIColor yellowColor] set];
    CGContextFillPath(context);
   
    [@"这是一个太阳?" drawAtPoint:CGPointMake(arc4random_uniform((int)sideLength), arc4random_uniform((int)sideLength)) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
