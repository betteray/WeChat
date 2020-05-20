//
//  FileUtil.m
//  WeChat
//
//  Created by ray on 2019/12/16.
//  Copyright © 2019 ray. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+ (void)saveFileWithData:(NSData *)data withFilePath:(NSString *)filePath {
    NSString *dirName = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileNamager = [NSFileManager defaultManager];
    if ([fileNamager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        }
        else {
            [data writeToFile:filePath atomically:YES];
        }
    }
}

+ (void)saveFileWithData2:(NSData *)data withFilePath:(NSString *)filePath {
    NSString *dirName = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileNamager = [NSFileManager defaultManager];
    if ([fileNamager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (data.length) {
            [data writeToFile:filePath atomically:YES];
        }
    }
}

@end
