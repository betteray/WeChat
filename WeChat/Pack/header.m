//
//  header.m
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import "header.h"
#import "Varint128.h"

@implementation header

+ (NSData *)make_header:(int)cgi
          encryptMethod:(EncryptMethod)encryptMethod
               bodyData:(NSData *)bodyData
     compressedBodyData:(NSData *)compressedBodyData
             needCookie:(BOOL)needCookie
                 cookie:(NSData *)cookie
                    uin:(uint32_t)uin

{
    
    int bodyDataLen = (int) [bodyData length];
    int compressedBodyDataLen = (int) [compressedBodyData length];
    
    NSMutableData *header = [NSMutableData data];
    
    [header appendData:[NSData dataWithHexString:@"BF"]]; //
    [header appendData:[NSData dataWithHexString:@"00"]]; //包头长度，最后计算。
    int len = (encryptMethod << 4) + (needCookie ? 0xf : 0x0);
    [header appendData:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", len]]];
    [header appendData:[NSData packInt32:CLIENT_VERSION flip:YES]];
    [header appendData:[NSData packInt32:uin flip:YES]];
    
    if (needCookie)
    {
        if ([cookie length] < 0xf)
        {
            [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
        }
        else
        {
            [header appendData:cookie];
        }
    }
    
    [header appendData:[Varint128 dataWithUInt32:cgi]];
    [header appendData:[Varint128 dataWithUInt32:bodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:compressedBodyDataLen]];
    
    if (need_login_rsa_verison(cgi))
    {
        [header appendData:[Varint128 dataWithUInt32:LOGIN_RSA_VER_172]];
        [header appendData:[NSData dataWithHexString:@"0D00"]];
        [header appendData:[NSData packInt16:9 flip:NO]];
    }
    else
    {
        [header appendData:[NSData dataWithHexString:@"000000000000000000000000000000"]];
    }
    
    [header replaceBytesInRange:NSMakeRange(1, 1) withBytes:[[Varint128 dataWithUInt32:(int)(([header length] << 2) + 0x2)] bytes]];
    return [header copy];
}

bool need_login_rsa_verison(int cgi)
{
    return cgi == 502 || cgi == 503 || cgi == 701;
}

@end
