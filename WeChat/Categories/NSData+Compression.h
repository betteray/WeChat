//
//  NSData+Compression.h
//  WXDemo
//
//  Created by ray on 2018/9/18.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBZlibErrorDomain;

typedef NS_ENUM(NSUInteger, BBZlibErrorCode) {
    BBZlibErrorCodeFileTooLarge = 0,
    BBZlibErrorCodeDeflationError = 1,
    BBZlibErrorCodeInflationError = 2,
    BBZlibErrorCodeCouldNotCreateFileError = 3,
};


@interface NSData (Compression)

- (NSData *)dataByDeflating;
- (NSData *)dataByInflatingWithError:(NSError * __autoreleasing *)error;

@end
