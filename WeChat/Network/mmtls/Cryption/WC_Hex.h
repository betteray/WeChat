//
//  WXHex.h
//  WXDemo
//
//  Created by ray on 2018/11/10.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WC_Hex : NSObject

+(NSData *) IV:(NSData *) IV XORSeq:(NSInteger) Seq;

@end
