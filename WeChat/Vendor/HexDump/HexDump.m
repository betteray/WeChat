//
//  HexDump.h
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

#import "HexDump.h"

static const NSUInteger BYTE_COUNT = 16;

NSString *hexDump(const void *buffer, const NSUInteger length)
{
    NSMutableString *s = [NSMutableString string];
    NSUInteger i = 0;
    
    // loop in blocks of BYTE_COUNT per line
    for (NSUInteger n = 0; n < length; n += BYTE_COUNT) {

        // print the memory offset of the current line
        [s appendFormat:@"%04lx ", (unsigned long)n];
        
        // print the next BYTE_COUNT bytes in hexadecimal format
        for (i = n; i < n + BYTE_COUNT && i < length; i++) {
            [s appendFormat:@"%02x ", ((const unsigned char *)buffer)[i]];
        }

        while (i < n + BYTE_COUNT) {
            [s appendString:@"   "];
            i++;
        }
        
        // display only printable characters next; non-ASCII and control
        // values are displayed as periods
        for (i = n; i < n + BYTE_COUNT && i < length; i++) {
            const unsigned char v = ((const unsigned char *)buffer)[i];
            BOOL visible = TRUE;
            if (v > 127 || iscntrl(v)) {
                visible = FALSE;
            }
            if (visible) {
                [s appendFormat:@"%c", (char)v];
            } else {
                [s appendString:@"."];
            }
        }
        
        while (i < n + BYTE_COUNT) {
            [s appendString:@" "];
            i++;
        }
        
        [s appendString:@"\n"];
    }
    
    return [NSString stringWithString:s];
}
