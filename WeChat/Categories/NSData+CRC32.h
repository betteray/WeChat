//
//  NSData+CRC32.h
//  IPAPatch-DummyApp
//
//  Created by ray on 2018/11/27.
//  Copyright © 2018 Weibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CRC32)

- (uint32_t) crc32;

@end
