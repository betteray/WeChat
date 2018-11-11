//
//  NSString+HexDump.m
//  DebugKit
//
//  Created by Chad Gibbons on 6/26/12.
//  Copyright (c) 2012 Nuclear Bunny Studios, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSString+HexDump.h"
#import "HexDump.h"

@implementation NSString (HexDump)

-(NSString *)hexDump:(NSStringEncoding)withEncoding
{
    NSString *dump = nil;

    const NSUInteger numberOfBytes = [self lengthOfBytesUsingEncoding:withEncoding];
    
    void *buffer = malloc(numberOfBytes);
    if (buffer != NULL) {
        NSUInteger usedLength = 0;
        NSRange range = NSMakeRange(0, [self length]);
        
        [self getBytes:buffer 
             maxLength:numberOfBytes 
            usedLength:&usedLength 
              encoding:withEncoding 
               options:0 
                 range:range 
        remainingRange:NULL];
        
        dump = hexDump(buffer, usedLength);
        
        free(buffer);
    }
    
    return dump;
}

@end
