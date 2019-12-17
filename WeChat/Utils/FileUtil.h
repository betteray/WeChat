//
//  FileUtil.h
//  WeChat
//
//  Created by ray on 2019/12/16.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUtil : NSObject

+ (void)saveFileWithData:(NSData *)data withFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
