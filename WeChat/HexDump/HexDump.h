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

#import <Foundation/Foundation.h>

//
// Dump a binary data buffer as a display of hexadecimal values and their
// ASCII-visible counterparts.
//
//   Parameters:
//     buffer - a pointer to the data buffer to dump
//     length - the length of the data buffer to display, in bytes
//
//   Return Value:
//     A NSString object containing the formatted hex dump. There are 16 bytes
//     displayed per line, separated into hexadecimal and printable character
//     values.
//
extern NSString *hexDump(const void *buffer, const NSUInteger length);
