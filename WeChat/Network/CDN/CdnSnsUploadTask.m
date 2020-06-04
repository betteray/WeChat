//
//  CdnTask.m
//  WeChat
//
//  Created by ray on 2019/12/9.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CdnSnsUploadTask.h"
#import <FastSocket.h>
#import "GetCDNDnsService.h"
#import "DeviceManager.h"
#import <zlib.h>
#import "FSOpenSSL.h"
#import "AES_EVP.h"

@interface CdnSnsUploadTask()

@end

@implementation CdnSnsUploadTask


- (void)packBody {
    CDNDnsInfo *snsDNSInfo = [self getDnsInfo];
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
    NSData *picData = [NSData dataWithContentsOfFile:self.picPath];

    NSData *aesKey = [FSOpenSSL random128BitAESKey];
    NSData *aesPicData = [AES_EVP AES_ECB_128_Encrypt:picData key:aesKey];
    unsigned long aesPicDataAdler32 = adler32(0, [aesPicData bytes], (unsigned int) [aesPicData length]);
    
    NSString *N = @"BFEDFFB5EA28509F9C89ED83FA7FDDA8"
                   "881435D444E984D53A98AD8E9410F114"
                   "5EDD537890E10456190B22E6E5006455"
                   "EFC6C12E41FDA985F38FBBC7213ECB81"
                   "0E3053D4B8D74FFBC70B4600ABD72820"
                   "2322AFCE1406046631261BD5EE3D4472"
                   "1082FEAB74340D73645DC0D02A293B96"
                   "2B9D47E4A64100BD7524DE00D9D3B5C1";
    
    NSString *E = @"10001";
    
    NSData *rsaValue = [FSOpenSSL RSA_PUB_EncryptData:aesKey modulus:N exponent:E];
    
    [self writeField:@"ver" WithValue:@"1"]; //uin
    [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%d", snsDNSInfo.uin]]; //uin
    [self writeField:@"seq" WithValue:[NSString stringWithFormat:@"%ld", self.seq]];
    [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //微信版本
    [self writeField:@"clientostype" WithValue:[device osType]]; // iOS12.4
    [self writeField:@"authkey" WithValue:snsDNSInfo.authKey.buffer]; //0x45长度 69 // /cgi-bin/micromsg-bin/getcdndns GetCDNDnsResponse snsDnsInfo authKey
    [self writeField:@"nettype" WithValue:@"1"];
    [self writeField:@"acceptdupack" WithValue:@"1"];
    [self writeField:@"rsaver" WithValue:@"1"];
    [self writeField:@"rsavalue" WithValue:rsaValue]; //0x80长度
    [self writeField:@"filetype" WithValue:@"20201"]; // 固定
    [self writeField:@"wxchattype" WithValue:@"0"];
    [self writeField:@"lastretcode" WithValue:@"0"];
    [self writeField:@"ipseq" WithValue:@"0"];
    [self writeField:@"isstorevideo" WithValue:@"0"];
    [self writeField:@"nocheckaeskey" WithValue:@"1"];
    [self writeField:@"enablehit" WithValue:@"1"];
    [self writeField:@"existancecheck" WithValue:@"0"];
    [self writeField:@"apptype" WithValue:@"107"]; // 固定
    NSString *fileKey = [FSOpenSSL md5StringFromString:[NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]]];
    [self writeField:@"filekey" WithValue:fileKey]; //md5(SystemClock.elapsedRealtime())
    [self writeField:@"totalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"rawtotalsize" WithValue:[NSString stringWithFormat:@"%ld", [picData length]]]; // 图片字节数
    [self writeField:@"localname" WithValue:@"sns_tmpb_Locall_path3"];
    [self writeField:@"offset" WithValue:@"0"];
    [self writeField:@"hasthumb" WithValue:@"0"];
    [self writeField:@"thumbtotalsize" WithValue:@"0"];
    [self writeField:@"rawthumbsize" WithValue:@"0"];
    [self writeField:@"rawthumbmd5" WithValue:[NSData data]];
    [self writeField:@"thumbcrc" WithValue:@"0"];
    [self writeField:@"largesvideo" WithValue:@"0"];
    [self writeField:@"sourceflag" WithValue:@"0"];
    [self writeField:@"advideoflag" WithValue:@"0"];
    
    NSString *picMD5 = [FSOpenSSL md5StringFromData:picData];
    [self writeField:@"filemd5" WithValue:picMD5]; // file md5
    [self writeField:@"rawfilemd5" WithValue:picMD5]; // file md5
    [self writeField:@"datachecksum" WithValue:[NSString stringWithFormat:@"%ld", aesPicDataAdler32]];

    unsigned long picAdler32 = adler32(0, [picData bytes], (unsigned int) [picData length]);
    [self writeField:@"filecrc" WithValue:[NSString stringWithFormat:@"%ld", picAdler32]]; // adler32 of file
    
    [self writeField:@"filedata" WithValue:picData];
    
    self.hasPacket = NO;
}

- (void)packHead {
    [self.head appendData:[NSData dataWithHexString:@"AB"]];   //固定
    [self.head appendData:[NSData packInt32:(int) (self.body.length + 25) flip:YES]]; // 包长 + 包头长
    [self.head appendData:[NSData dataWithHexString:@"27127916e88600000000000000000000"]];   //固定
    [self.head appendData:[NSData packInt32:(int) self.body.length flip:YES]]; // 包长
}

#pragma mark - Helper

- (NSString *)getIp {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return [resp.snsDnsInfo.frontIplistArray objectAtIndex:0].string;
}

- (CDNDnsInfo *)getDnsInfo {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return resp.snsDnsInfo;
}

@end
