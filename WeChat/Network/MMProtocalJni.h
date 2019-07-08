//
//  MMProtocalJni.h
//  WeChat
//
//  Created by ysh on 2019/7/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMProtocalJni : NSObject

+ (int) genSignatureWithUin:(int)uin
                   ecdhKey:(NSData *)ecdhKey
              protofufData:(NSData *)probufData;

@end

NS_ASSUME_NONNULL_END
