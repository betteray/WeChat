//
//  short_pack.m
//  WeChat
//
//  Created by ray on 2018/12/20.
//  Copyright © 2018 ray. All rights reserved.
//

#import "short_pack.h"
#import "header.h"
#import "NSData+CompressAndEncypt.h"

#import "ShortPackage.h"
#import "ShortHeader.h"

#import "FSOpenSSL.h"

@implementation short_pack

+ (NSData *)pack:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type uin:(uint32_t)uin cookie:(NSData *)cookie
{
    switch (type)
    {
        case 1:
        {
            NSData *head = [header make_header:cgi encryptMethod:NONE bodyData:serilizedData compressedBodyData:serilizedData needCookie:NO cookie:nil uin:uin];
            NSData *body = [FSOpenSSL RSA_PUB_EncryptData:serilizedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];
            
            return [longlinkBody copy];
        }
            break;
        case 5:
        {
            NSData *head = [header make_header:cgi encryptMethod:AES bodyData:serilizedData compressedBodyData:serilizedData needCookie:YES cookie:cookie uin:uin];
            LogDebug(@"AES Before: \n\n%@\n", serilizedData.hexDump);
            NSData *body = [serilizedData AES];
            LogDebug(@"AES After: \n\n%@\n", body.hexDump);
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];
            return [longlinkBody copy];
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (ShortPackage *)unpack:(NSData *)body
{
    ShortPackage *package = [ShortPackage new];
    ShortHeader *shortHeader = [ShortHeader new];
    
    package.header = shortHeader;
    if ([body length] < 0x20)
    {
        LogError(@"UnPack BF Fail, Body too short.");
        return nil;
    }
    
    NSInteger index = 0;
    int mark = (int) [body toInt8ofRange:index];
    if (mark == 0xbf)
    {
        index++;
    }
    int32_t headLength = (int) [body toInt8ofRange:index] >> 2;
    shortHeader.compressed = (1 == ((int) [body toInt8ofRange:index] & 0x3));
    index++;
    
    shortHeader.decrytType = (int) [body toInt8ofRange:index] >> 4;
    int cookieLen = (int) [body toInt8ofRange:index] & 0xf;
    index++;
    index += 4; //服务器版本，忽略。
    
    package.uin = (int) [body toInt8ofRange:index];
    index += 4;
    
    if (cookieLen > 0 && cookieLen <= 0xf)
    {
        NSData *cookie = [body subdataWithRange:NSMakeRange(index, cookieLen)];
        LogInfo(@"Cookie: %@", cookie);
        index += cookieLen;
        [[DBManager sharedManager] setCookie:cookie];
    }
    else if (cookieLen > 0xf)
    {
        LogError(@"UnPack BF Fail, cookieLen too long.");
        return nil;
    }
    
    int cgi = 0;
    int dwLen = [self decode:&cgi bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    shortHeader.cgi = cgi;
    index += dwLen;
    
    int protobufLen = 0;
    dwLen = [self decode:&protobufLen bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    index += dwLen;
    
    int compressedLen = 0;
    dwLen = [self decode:&compressedLen bytes:[body subdataWithRange:NSMakeRange(index, 5)] off:0];
    //后面的数据无视。
    
    //解包完毕，取包体。
    
    if (headLength < [body length])
    {
        package.body = [body subdataWithRange:NSMakeRange(headLength, [body length] - headLength)];
    }
    
    return package;
}

//
+ (int)decode:(int *)apuValue bytes:(NSData *)apcBuffer off:(int)off
{
    int num3;
    int num = 0;
    int num2 = 0;
    int num4 = 0;
    int num5 = *(int *) [[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    while ((num5 & 0xff) >= 0x80)
    {
        num3 = num5 & 0x7f;
        num4 += num3 << num2;
        num2 += 7;
        num5 = *(int *) [[apcBuffer subdataWithRange:NSMakeRange(off + num++, 1)] bytes];
    }
    num3 = num5;
    num4 += num3 << num2;
    *apuValue = num4;
    return num;
}

@end
