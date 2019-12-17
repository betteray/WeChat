//
//  CalRqtAlg.h
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalRqtAlg : NSObject

+ (int)calRqtData:(NSData *)data cmd:(unsigned int)cmd uin:(unsigned int)uin;

@end

NS_ASSUME_NONNULL_END
