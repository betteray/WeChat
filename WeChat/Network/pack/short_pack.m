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
#import "Cookie.h"
#import "Varint128.h"
#import "NSData+Compression.h"
#import "NSData+AES.h"

@implementation short_pack

+ (NSData *)pack:(int)cgi serilizedData:(NSData *)serilizedData type:(NSInteger)type uin:(uint32_t)uin cookie:(NSData *)cookie
{
    switch (type)
    {
        case 1:
        {
            NSData *head = [header make_header3:cgi encryptMethod:RSA bodyData:serilizedData compressedBodyData:serilizedData needCookie:NO cookie:nil uin:uin];
            NSData *body = [FSOpenSSL RSA_PUB_EncryptData:serilizedData modulus:LOGIN_RSA_VER172_KEY_N exponent:LOGIN_RSA_VER172_KEY_E];
            NSMutableData *longlinkBody = [NSMutableData dataWithData:head];
            [longlinkBody appendData:body];
            
            return [longlinkBody copy];
        }
            break;
        case 5:
        {
            NSData *head = [header make_header:cgi encryptMethod:AES bodyData:serilizedData compressedBodyData:serilizedData needCookie:YES cookie:cookie uin:uin];
            NSData *body = [serilizedData AES];
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

+ (NSData *)EncodeHybirdEcdhEncryptPack:(int)cgi
                          serilizedData:(NSData *)serilizedData
                                    uin:(uint32_t)uin
                                 cookie:(NSData *)cookie
                             rsaVersion:(int)rsaVersion
{
    
    int bodyDataLen = (int) [serilizedData length];
    int compressedBodyDataLen = (int) [serilizedData length];
    
    NSMutableData *header = [NSMutableData data];
    
    [header appendData:[NSData dataWithHexString:@"00"]];   //包头长度及是否使用压缩，最后计算。
    int len = (0xc << 4) + (cookie != nil ? 0xf : 0x0);     //加密算法及是否使用cookie： 0xc=HybirdEcdhEncrypt
    [header appendData:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", len]]];
    [header appendData:[NSData packInt32:CLIENT_VERSION flip:YES]];
    [header appendData:[NSData packInt32:uin flip:YES]];
    
    if (cookie) [header appendData:cookie];
    
    [header appendData:[Varint128 dataWithUInt32:cgi]];
    [header appendData:[Varint128 dataWithUInt32:bodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:compressedBodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:rsaVersion]];
    
    [header appendData:[NSData dataWithHexString:@"02"]];

    NSData *headerLen = [NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) (([header length] << 2) + 0x2)]]; //0x2 !use_compress
    [header replaceBytesInRange:NSMakeRange(0, 1) withBytes:[headerLen bytes]];
    
    [header appendData:serilizedData];
    
    return [header copy];
}

+ (NSData *)EncodePack:(int)cgi
         serilizedData:(NSData *)serilizedData
                   uin:(uint32_t)uin
                aesKey:(NSData *)aesKey
                cookie:(NSData *)cookie
             signature:(int)signature
{
    
    int bodyDataLen = (int) [serilizedData length];
    NSData *compressData = [serilizedData dataByDeflating];
    int compressedBodyDataLen = (int) [compressData length];
    NSData *aesedData = [compressData AES_CBC_encryptWithKey:aesKey];

    NSMutableData *header = [NSMutableData data];
    
    [header appendData:[NSData dataWithHexString:@"bf"]];   //固定
    [header appendData:[NSData dataWithHexString:@"00"]];   //包头长度及是否使用压缩，最后计算。
    int len = (0x5 << 4) + (cookie != nil ? 0xf : 0x0);     //加密算法及是否使用cookie： 0x5=aes
    [header appendData:[NSData dataWithHexString:[NSString stringWithFormat:@"%2x", len]]];
    [header appendData:[NSData packInt32:CLIENT_VERSION flip:YES]];
    [header appendData:[NSData packInt32:uin flip:YES]];
    
    if (cookie) [header appendData:cookie];
    
    [header appendData:[Varint128 dataWithUInt32:cgi]];
    [header appendData:[Varint128 dataWithUInt32:bodyDataLen]];
    [header appendData:[Varint128 dataWithUInt32:compressedBodyDataLen]];
    
    [header appendData:[NSData dataWithHexString:@"0002"]];
    [header appendData:[Varint128 dataWithUInt32:signature]];//checksum
    [header appendData:[NSData dataWithHexString:@"010000"]];

    NSData *headerLen = [NSData dataWithHexString:[NSString stringWithFormat:@"%2x", (int) (([header length] << 2) + 0x2)]]; //0x2 !use_compress
    [header replaceBytesInRange:NSMakeRange(1, 1) withBytes:[headerLen bytes]];
    [header appendData:aesedData];
    
    return [header copy];
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
    
    UInt32 index = 0;
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
        LogVerbose(@"Cookie: %@", cookie);
        index += cookieLen;
        
        [WeChatClient sharedClient].cookie = cookie;
        
        //更新cookie到数据库
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [Cookie createOrUpdateInDefaultRealmWithValue:@[CookieID, cookie]];
        [realm commitWriteTransaction];
    }
    else if (cookieLen > 0xf)
    {
        LogError(@"UnPack BF Fail, cookieLen too long.");
        return nil;
    }
    
    shortHeader.cgi = [Varint128 decode32FromBytes:[body bytes] offset:&index];
    [Varint128 decode32FromBytes:[body bytes] offset:&index];   //int protobufLen
    [Varint128 decode32FromBytes:[body bytes] offset:&index];   //int compressedLen =
    
    if (headLength < [body length])
    {
        package.body = [body subdataWithRange:NSMakeRange(headLength, [body length] - headLength)];
    }
    
    return package;
}

@end
