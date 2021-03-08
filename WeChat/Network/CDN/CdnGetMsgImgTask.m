//
//  CdnGetMsgImgTask.m
//  WeChat
//
//  Created by ray on 2020/6/4.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CdnGetMsgImgTask.h"
#import "FSOpenSSL.h"
#import "AES_EVP.h"
#import <zlib.h>
#import "GetCDNDnsService.h"

@implementation CdnGetMsgImgTask

- (void)packBody {
    CDNDnsInfo *dnsInfo = [self getDnsInfo];
    WCDevice *device = [[DeviceManager sharedManager] getCurrentDevice];
   
    NSData *aesKey = [NSData dataWithHexString:self.aesKey]; //
   
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

    [self writeField:@"ver" WithValue:@"1"]; //固定
    [self writeField:@"weixinnum" WithValue:[NSString stringWithFormat:@"%u", dnsInfo.uin]]; //ok snsDNSInfo.uin
    [self writeField:@"seq" WithValue:[@(self.seq) stringValue]]; //ok // self.seq
    [self writeField:@"clientversion" WithValue:[NSString stringWithFormat:@"%d", CLIENT_VERSION]]; //ok
    [self writeField:@"clientostype" WithValue:[device osType]];
    [self writeField:@"authkey" WithValue:dnsInfo.authKey.buffer]; //ok
    [self writeField:@"nettype" WithValue:@"1"];//按需填入
    [self writeField:@"acceptdupack" WithValue:@"1"]; //固定
    
    [self writeField:@"rsaver" WithValue:@"1"]; //固定
    [self writeField:@"rsavalue" WithValue:rsaValue]; //固定 //todo
    [self writeField:@"filetype" WithValue:@"2"]; //
    [self writeField:@"wxchattype" WithValue:@"0"]; //
    [self writeField:@"fileid" WithValue:self.fileid]; //固定 //todo
    [self writeField:@"lastretcode" WithValue:@"0"]; //
    [self writeField:@"ipseq" WithValue:@"0"]; //
    [self writeField:@"cli-quic-flag" WithValue:@"0"]; //
    [self writeField:@"wxmsgflag" WithValue:@""]; // 值的长度为0，给""字串吧
    [self writeField:@"wxautostart" WithValue:@"1"]; //
    [self writeField:@"downpicformat" WithValue:@"1"]; //
    [self writeField:@"offset" WithValue:@"0"]; //
    [self writeField:@"largesvideo" WithValue:@"0"]; //
    [self writeField:@"sourceflag" WithValue:@"0"]; //

    self.hasPacket = NO;
}

- (void)packHead {
    [self.head appendData:[NSData dataWithHexString:@"AB"]];   //固定
    [self.head appendData:[NSData packInt32:(int) (self.body.length + 25) flip:YES]]; // 包长 + 包头长
    
    [self.head appendData:[NSData dataWithHexString:@"4E20"]];   //固定cdn type? 图片 视频 上传 下载
    CDNDnsInfo *dnsInfo = [self getDnsInfo];
    NSData *uin = [NSData packInt32:dnsInfo.uin flip:NO];
    [self.head appendData:uin];   //uin data
    [self.head appendData:[NSData dataWithHexString:@"00000000000000000000"]];   //固定

    [self.head appendData:[NSData packInt32:(int) self.body.length flip:YES]]; // 包长
    
    self.hasPacket = NO;
}

- (NSString *)getIp {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return [resp.dnsInfo.frontIplistArray objectAtIndex:0].string;
}

- (CDNDnsInfo *)getDnsInfo {
    GetCDNDnsResponse *resp = [GetCDNDnsService getCDNDnsResponseFromCache];
    return resp.dnsInfo;
}

@end
