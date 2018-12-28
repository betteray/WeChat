//
//  long_pack.h
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LongPackage.h"
#import "LongHeader.h"

@interface long_pack : NSObject

+ (NSData *)packWithUIN:(int32_t)uin
                    seq:(int)seq
                  CmdId:(int)cmdId
                    cgi:(int)cgi
          serilizedData:(NSData *)serilizedData
                   type:(NSInteger)type;

+ (NSData *)pack:(int)seq
           cmdId:(int)cmdId
       shortData:(NSData *)shortData;


+ (LongPackage *)unpack:(NSData *)recvdRawData;
+ (LongHeader *)unpackLongHeder:(NSData *)longHeaderData;

@end
