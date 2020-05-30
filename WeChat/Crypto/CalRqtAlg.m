//
//  CalRqtAlg.m
//  WeChat
//
//  Created by ray on 2019/12/13.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CalRqtAlg.h"
#import "FSOpenSSL.h"

#define RQT_KEY @"6a664d5d537c253f736e48273a295e4f"

@implementation CalRqtAlg

+ (int)calRqtData:(NSData *)data cmd:(unsigned int)cmd uin:(unsigned int)uin {
    NSString *md5 = [FSOpenSSL md5StringFromData:data];
    NSData *rqtKeyData = [NSData dataWithHexString:RQT_KEY];
    NSMutableData *block = [[rqtKeyData addDataAtTail:
                             [NSData dataWithHexString:@"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"]]
                            mutableCopy]; // 48 byte 00
    Byte *mutableBytes = (Byte *) [block mutableBytes];
    for (int i=0; i<[block length]; i++) {
        mutableBytes[i] ^= 0x36;
    }
    
    [block appendData:[md5 dataUsingEncoding:NSUTF8StringEncoding]];
    
//    LogVerbose(@"%@", block);
   
    // ok ======== ^^^^^^^ ===========
    
    NSMutableData *block2 = [[rqtKeyData addDataAtTail:
                              [NSData dataWithHexString:@"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"]]
                             mutableCopy]; // 48 byte 00 // 48 byte 00
    Byte *mutableBlock2 = (Byte *) [block2 mutableBytes];
    for (int i=0; i<[block2 length]; i++) {
        mutableBlock2[i] ^= 0x5c;
    }
    
    NSData *sha1 = [FSOpenSSL sha1DataFromData:block];
    [block2 appendData:sha1];
    NSData *sha2 = [FSOpenSSL sha1DataFromData:block2];
    Byte *sha2Bytes = (Byte *) [sha2 bytes];
    int t1 = 0, t2 = 0, t3 = 0;
    for (int i=2; i< sha2.length; i++) {
        int v1 = sha2Bytes[i-2] & 0xff;
        int v2 = sha2Bytes[i-1] & 0xff;
        int v3 = sha2Bytes[i] & 0xff;
        
        t1 = 0x83 * t1 + v1;
        t2 = 0x83 * t2 + v2;
        t3 = 0x83 * t3 + v3;
    }
    
    int r3 = t1 & 0x7f;
    int r4 = (t3 << 16) & 0x7f0000;
    int r5 = (t2 << 8) & 0x7f00;
    
    return r3 | r4 | r5 | ((uin<<5 | (cmd&0x1f)) << 24);
}

@end
