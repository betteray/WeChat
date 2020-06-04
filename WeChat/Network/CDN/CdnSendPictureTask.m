//
//  CdnSendPictureTask.m
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnSendPictureTask.h"
#import "FSOpenSSL.h"
#import "AES_EVP.h"
#import <zlib.h>
#import "GetCDNDnsService.h"

#define CDN_USERNAME_KEY @"wxusrname2016cdn"

@interface CdnSendPictureTask ()

@property (nonatomic, assign) BOOL hasSendShortPackage;

@end

@implementation CdnSendPictureTask

- (instancetype)initWithSeq:(NSUInteger)seq {
    self = [super initWithSeq:seq];
    if (self) {
        _hasSendShortPackage = YES; //控制是否需要发送图片数据上面那个短的数据包，测试发不发都可以发送成功。
    }
    
    return self;
}


#pragma mark - Request

- (void)packBody {
    CDNDnsInfo *dnsInfo = [self getDnsInfo];
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    
    if (!_hasSendShortPackage) {
        //_hasSendShortPackage = YES;// put it in packHead.
        [self writeField:@"ver" WithValue:@"1"]; //固定
        [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%d", dnsInfo.uin]]; //ok snsDNSInfo.uin
        [self writeField:@"seq" WithValue:[@(self.seq) stringValue]]; //ok // self.seq
        [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //ok
        [self writeField:@"clientostype" WithValue:[device osType]];
        [self writeField:@"authkey" WithValue:dnsInfo.authKey.buffer]; //ok
        [self writeField:@"nettype" WithValue:@"1"];//按需填入
        [self writeField:@"acceptdupack" WithValue:@"1"]; //固定
    } else {
        NSData *picData = self.pics[@"image"];
        unsigned long filecrc = adler32(0, [picData bytes], (unsigned int) [picData length]);

        NSData *aesKey = [NSData dataWithHexString:self.aesKey];//[FSOpenSSL random128BitAESKey];
        NSData *aesPicData = [AES_EVP AES_ECB_128_Encrypt:picData key:aesKey];
        unsigned long datachecksum = adler32(0, [aesPicData bytes], (unsigned int) [aesPicData length]);
        NSString *picMD5 = [FSOpenSSL md5StringFromData:picData];
        
        NSData *midPicData = self.pics[@"mid"];
        NSData *aesMidPicData = [AES_EVP AES_ECB_128_Encrypt:midPicData key:aesKey];
        NSString *midImgMD5 = [FSOpenSSL md5StringFromData:midPicData];

        NSData *thumbPicData = self.pics[@"thumb"];
        NSData *aesthumbPicData = [AES_EVP AES_ECB_128_Encrypt:thumbPicData key:aesKey];
        unsigned long encthumbcrc = adler32(0, [aesthumbPicData bytes], (unsigned int) [aesthumbPicData length]);
        NSString *rawthumbmd5 = [FSOpenSSL md5StringFromData:thumbPicData];

        NSString *touser = [NSString stringWithFormat:@"@cdn2_%@", [AES_EVP encrypedUserName:self.toUser WithKey:CDN_USERNAME_KEY]];
        
        [self writeField:@"ver" WithValue:@"1"]; //固定
        [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%d", dnsInfo.uin]]; //ok snsDNSInfo.uin
        [self writeField:@"seq" WithValue:[@(self.seq) stringValue]]; //ok // self.seq
        [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //ok
        [self writeField:@"clientostype" WithValue:[device osType]];
        [self writeField:@"authkey" WithValue:dnsInfo.authKey.buffer]; //ok
        [self writeField:@"nettype" WithValue:@"1"];//按需填入
        [self writeField:@"acceptdupack" WithValue:@"1"]; //固定
        [self writeField:@"safeproto" WithValue:@"1"]; //固定
        [self writeField:@"filetype" WithValue:@"1"];//固定
        [self writeField:@"wxchattype" WithValue:@"0"]; //固定
        [self writeField:@"lastretcode" WithValue:@"0"];//固定
        [self writeField:@"ipseq" WithValue:@"0"];//固定
        [self writeField:@"cli-quic-flag" WithValue:@"0"];//固定
        [self writeField:@"hasthumb" WithValue:@"1"];//固定
        [self writeField:@"touser" WithValue:touser]; // todo //固定？
        [self writeField:@"compresstype" WithValue:@"0"];//固定
        [self writeField:@"nocheckaeskey" WithValue:@"1"];//固定
        [self writeField:@"enablehit" WithValue:@"1"];//固定
        [self writeField:@"existancecheck" WithValue:@"0"];//固定
        [self writeField:@"apptype" WithValue:@"1"];//固定
        [self writeField:@"filekey" WithValue:self.fileKey]; // 前边先固定？？
        [self writeField:@"totalsize" WithValue:[@(aesPicData.length) stringValue]]; //ok
        [self writeField:@"rawtotalsize" WithValue:[@(picData.length) stringValue]]; // 原始图片的大小
        [self writeField:@"localname" WithValue:[NSString stringWithFormat:@"%@.jpg", [FSOpenSSL md5StringFromData:picData]]];//ok
        [self writeField:@"sessionbuf" WithValue:self.sessionbuf]; // MMProtocalJni::pack 发消息组完的bf包。
        [self writeField:@"offset" WithValue:@"0"];//固定
        [self writeField:@"thumbtotalsize" WithValue:[@(aesthumbPicData.length) stringValue]]; //ok
        [self writeField:@"rawthumbsize" WithValue:[@(thumbPicData.length) stringValue]]; //th_xxxx 图片的大小
        [self writeField:@"rawthumbmd5" WithValue:rawthumbmd5]; // 等于 th_xxxx 的md5.
        [self writeField:@"encthumbcrc" WithValue:[@(encthumbcrc) stringValue]]; // ok
        [self writeField:@"thumbdata" WithValue:aesthumbPicData]; //ok
        [self writeField:@"midimgrawsize" WithValue:[@(midPicData.length) stringValue]]; // mid 图片aes前数据的大小
        [self writeField:@"midimgtotalsize" WithValue:[@(aesMidPicData.length) stringValue]]; //midimgdata这个字段的数据长度，即aes后的数据长度。
        [self writeField:@"midimgchecksum" WithValue:@"0"]; //0就是0
        [self writeField:@"midimgmd5" WithValue:midImgMD5]; //ok
        [self writeField:@"midimgdata" WithValue:aesMidPicData]; //ok
        [self writeField:@"largesvideo" WithValue:@"0"];//固定
        [self writeField:@"sourceflag" WithValue:@"0"]; ////固定
        [self writeField:@"advideoflag" WithValue:@"0"];//固定
        [self writeField:@"filemd5" WithValue:picMD5]; //md5(pic.jpg)
        [self writeField:@"rawfilemd5" WithValue:picMD5]; // 等于filemd5即图片的md5
        [self writeField:@"datachecksum" WithValue:[NSString stringWithFormat:@"%ld", datachecksum]];//ok
        [self writeField:@"filecrc" WithValue:[@(filecrc) stringValue]]; //ok
        [self writeField:@"setofpicformat" WithValue:@"111000"]; ////固定
        [self writeField:@"filedata" WithValue:aesPicData]; //ok
        
        self.hasPacket = NO;
    }
}

- (void)packHead {
    if (!_hasSendShortPackage) {
        _hasSendShortPackage = YES;
        [self.head appendData:[NSData dataWithHexString:@"AB"]];   //固定
        [self.head appendData:[NSData packInt32:(int) (self.body.length + 25) flip:YES]]; // 包长 + 包头长
        [self.head appendData:[NSData dataWithHexString:@"2714FFFFFF7F00000000000000000000"]];   //固定
        [self.head appendData:[NSData packInt32:(int) self.body.length flip:YES]]; // 包长
    } else {
        [self.head appendData:[NSData dataWithHexString:@"AB"]];   //固定
        [self.head appendData:[NSData packInt32:(int) (self.body.length + 25) flip:YES]]; // 包长 + 包头长
        [self.head appendData:[NSData dataWithHexString:@"2710FFFFFF7F00000000000000000000"]];   //固定
        [self.head appendData:[NSData packInt32:(int) self.body.length flip:YES]]; // 包长
        
        self.hasPacket = NO;
    }
}

- (NSString *)getIp {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return [resp.fakeDnsInfo.frontIplistArray objectAtIndex:0].string;
}

- (CDNDnsInfo *)getDnsInfo {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return resp.fakeDnsInfo;
}

@end
