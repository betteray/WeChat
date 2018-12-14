//
//  WXHex.m
//  WXDemo
//
//  Created by ray on 2018/11/10.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WX_Hex.h"

@implementation WX_Hex

+(NSData *) IV:(NSData *) IV XORSeq:(NSInteger) Seq {
    NSMutableData *prefixData = [[NSData dataWithHexString:@"0000000000000000"] mutableCopy];
    NSData *seqData = [NSData packInt32:(int32_t)Seq flip:YES];
    [prefixData appendData:seqData];
    
    const char *data1Bytes = [IV bytes];
    const char *data2Bytes = [prefixData bytes];
    // Mutable data that individual xor'd bytes will be added to
    NSMutableData *xorData = [[NSMutableData alloc] init];
    for (int i = 0; i < IV.length; i++){
        const char xorByte = data1Bytes[i] ^ data2Bytes[i];
        [xorData appendBytes:&xorByte length:1];
    }
    return xorData;
}

@end
