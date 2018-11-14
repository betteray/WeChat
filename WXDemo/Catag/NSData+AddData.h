//
//  NSData+AddData.h
//  WXDemo
//
//  Created by ray on 2018/11/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AddData)

- (NSData *)addDataAtTail:(NSData *)data;

- (NSData *)addDataAtHead:(NSData *)data;

@end
