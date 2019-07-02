//
//  NewInitViewController.m
//  WeChat
//
//  Created by ray on 2018/12/17.
//  Copyright © 2018 ray. All rights reserved.
//

#import "TestViewController.h"
#import "SyncKeyCompare.h"
#import "WCECDH.h"
#import "WC_SHA256.h"
#import "WC_AesGcm128.h"
#import "WC_HKDF.h"
#import "Varint128.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)Test:(id)sender {

}

- (IBAction)registerr:(id)sender {

}

- (IBAction)register:(id)sender {
    NSData *data = [NSData dataWithHexString:@"8A01B6109D"];


    NSString *binPath = [[NSBundle mainBundle] pathForResource:@"secmanualauth-type-252" ofType:@"bin"];
    NSData *secManualAuth = [NSData dataWithContentsOfFile:binPath];
    ManualAuthRequest *request = [ManualAuthRequest parseFromData:secManualAuth error:nil];

    SyncKey *resp = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12080802 10a2f9d6 9e021208 080310cd f6d69e02 12040804 10001204 08051000 12040807 10001208 080810a3 f8d69e02 12080809 10b0f7d6 9e021204 080a1000 1208080b 10fde6d6 9e021208 080d10f1 dcd59e02 1208080e 10f1dcd5 9e021208 081010f1 dcd59e02 12080811 10f1dcd5 9e021204 08651000 12040866 10001204 08671000 12040868 10001204 08691000 1204086b 10001204 086d1000 1204086f 10001204 08701000 12040872 10001209 08c90110 f3f3cae1 05120508 cb011000 120508cc 01100012 0508cd01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];

    SyncKey *req = [[SyncKey alloc] initWithData:[NSData dataWithHexString:[@"081f1208 080110c6 f9d69e02 12040865 10001208 080210be f9d69e02 12040866 10001208 080d10f1 dcd59e02 120508cc 01100012 08080310 cdf6d69e 02120408 67100012 08080b10 fde6d69e 02120408 6f100012 04080410 00120408 68100012 04080510 00120408 69100012 04080710 00120408 6b100012 08080810 a3f8d69e 02120808 0910b0f7 d69e0212 08081010 f1dcd59e 02120808 1110f1dc d59e0212 04087210 00120808 0e10f1dc d59e0212 04087010 00120408 6d100012 04080a10 00120908 c90110fc 88cce105 120508cd 01100012 0508cb01 10001209 08e80710 a4d1bbe1 05120908 e907108c d3bbe105 120908d1 0f108593 c1e105" stringByReplacingOccurrencesOfString:@" " withString:@""]] error:nil];

    [SyncKeyCompare compaireOldSyncKey:resp newSyncKey:req];
}

- (IBAction)test:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"st_angler_1" ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);

    [self testNeedRSAPack];
}

#define ARRAY_SIZE(x) sizeof(x)/sizeof((x)[0])

- (void)testNeedRSAPack {
    NSData *pri = [NSData dataWithHexString:[@"0495BC6E 5C1331AD 172D0F35 B1792C3C E63F9157 2ABD2DD6 DF6DAC2D 70195C3F 6627CCA6 0307305D 8495A8C3 8B4416C7 5021E823 B6C97DFF E79C14CB 7C3AF8A5 86" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *pub = [NSData dataWithHexString:[@"30770201 01042013 15E00052 D8219F93 E5C92B46 2835D163 06AA42DC 57B4768E EE02B892 CA7557A0 0A06082A 8648CE3D 030107A1 44034200 04E74914 8BEEDEB5 2CF604C5 9FFEA2F6 5C47F9B5 EE4D5D3F E6AFABFD E1A53100 A0DA74D1 7D2F9D89 3CC1F792 A457E813 D776E53C 6F961DBE AF1995E9 A90B12EB DA" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *ecdhResult = [WCECDH DoEcdh2:415 ServerPubKey:pri LocalPriKey:pub];
    LogVerbose(@"%@", ecdhResult);

    NSData *shaplainText = [NSData dataWithHexString:[@"31343135 04115F2F 4C94BDDC 02F72F46 3B6F6B0E FA5BA4B8 062B1738 FC20BA39 E2FEF8E6 CA5F4C69 1DC5F2A4 5BC0C88D A97A7571 6118B693 998E8843 00AFD091 BE7995C1 C7" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *sha256 = [WC_SHA256 sha256:shaplainText];
    LogVerbose(@"%@", sha256);

    //OK
    NSData *aesPData = [NSData dataWithHexString:[@"789C8555 4D6C1B45 14B6ABB4 0A56A191 A9384415 1AE50055 20DE99D9 D9DDD9B0 1929490D 499538C5 49834042 D17877FC A35DAF8D 77EDD09E 1048A802 2E70E000 1CE91128 02210EE5 C401F5C4 B95C10A8 378440A2 3784C4BC B1036E14 A94AF4F6 CDF766DE CFB7DFAC 4B9F174B E767E7CA 73F72E7C F573F8F7 132B3F1E FEF2DEBA B3FF4779 6DF6CEE9 F2CAAC5F F6677EEF BC5A118F B61EB970 E3EEED17 ACF8E6AD FBFBE7CB 9777EF6E A98DA77F BD3FF7E1 776FD1F7 FFFA33FC E7DD1BB7 7F38F3CD BDE88B8F 3EF9ECE6 97BFFD34 FFD833DC 258E43F5 1F980514 BA76A8A2 46287DC6 1B583538 97368F9C D066D4F7 79132F3E 7447F9FB B3A5C552 61AE303F B7DAC0BE 725DACB8 623CA405 F4F5DB6F 7C7B6AB1 24D368D0 EB444BD4 C3C5F2C5 D2CC6CA1 5C289F2D 693B5F58 30ABF919 588DFD45 637161FE 1C773D9F 534C31F7 3DCEF0C2 C7B341D6 6BE6F9B5 BE124112 E6DD5E28 70604DBC 20512395 08A201E3 04311118 05967E04 3115326D 256AB084 ED0AF734 4835680B 5E21159D 417B41CC C4B17A1A 671A7784 76B4895D 70B4893D D1642A0A 231646D4 26CD268D 74C0D301 2ED6F737 BC1A71D6 08C398FA 5C37A3C1 20F6454D BD3ECC90 7B45033E B4860587 D630F844 BC389449 D8EB76D1 9E0ADB69 2FE9B53A 2A7B166D A621DADE DDE6BECF 60330C42 28740136 26B671A1 77C204A6 CB184FFF 430CFA27 CEC93118 89B8A22D 9326CADB C36E0335 65967787 498E46CD 3E5251D6 47A9EAA5 B01AD928 4F32E331 D4893A23 696C8ED4 28CFF241 174995A1 BE3E9BA0 AC2D0918 8AC24168 53A8049C 112E080F 35C34DEC 114F4AD7 6B50D9F0 6CE639D8 6948EC29 20910059 94889DBE 4A5F1AE4 F09ECCDB 3343838D E9C99352 9894BAC2 F850CFC6 E2A9D786 BDFCB949 AAF1025E 35506EDB 42D35DC9 551AAA34 AF74BB10 00226D26 5ABD9E56 8A35D6CB E4B16C84 62ED5CD9 F62A8413 8A9D0AC6 C47230C7 84E3E561 A6770E54 A264A696 62752D83 74D091ED 4C740700 106EBB53 42F47C80 4DB7DEA4 2C00A024 9B4F1D04 526C7F0A 000531FC 3FC06026 46CCF40C 0863546C 0CE5A1EA 0000B431 5BA4FAED C0D2689D 8DF7428F CC081C6C CC8CC4C1 C6CC1387 9DA6390F FD307ED2 ED80C698 2FAC48E6 D2322460 EB415E2D D806ED3A D45474A0 19C71EFB D089E309 B82BB084 3A0E37B7 0D123BBE B0C187D3 2E36770F C67489C8 0743204A 7B81F5DF 07E16281 3E79EC03 A40E88E3 12D7A70C 7B8EED2D A3872970 EDDC98B5 A5A3DB7A F9D35341 A4469D50 75D2664F 04DBABB5 ABCFAFAE EF5DAD57 EB28955D B5B2303E B1A0633B 97AA5B13 F0E8BC86 F7ABF5DD CD9DDA41 BDBA555D DDAD4E36 183D4D45 376BEBF5 EA76B5B6 B77A9422 6C30AEBF AF5A5E7A DBA5CDDD 2B5BAB2F 4F424927 55B2A50E 264A02E2 23D518B6 90C98A8E A9143D90 C99AA4D2 DE09B5A7 D049BF1A 3183C173 6A78BD9C E2A57EFA 7AFB60BD F6CA0CD7 05DB857E E1FA99B1 9CDF2C3E 7E44851C 74956C74 96469E7C A738F593 F041B170 AB58FC17 B66B01B8" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *aadData = [NSData dataWithHexString:[@"E1C059A0 604BA42D D829428A B34A7C56 B91F156E C231DE3C AD61C635 4E786FAD" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *keyData = [NSData dataWithHexString:[@"13B065F6 74848CC0 25F15795 9BDED726 6EA97C39 5E6CD5A5" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *ivData = [NSData dataWithHexString:[@"57BC4BC5 C31C7C67 5C3F794B" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *cData = [WC_AesGcm128 aes192gcmEncrypt:aesPData aad:aadData key:keyData ivec:ivData];
    LogVerbose(@"%@", cData);

    //hkdf

    NSData *saltData = [NSData dataWithHexString:[@"73656375 72697479 2068646B 66206578 70616E64" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *ikmData = [NSData dataWithHexString:[@"D2CA9AD2 F718E30E FA580984 C2B3BFAD 538A2986 B4244998 97C44C00 E99426AA" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSData *infoData = [NSData dataWithHexString:[@"891BE9A0 5F813B88 3430ACE2 4D63817A 6EDC38B2 386EFB2C B1CC9097 FD3F6F84" stringByReplacingOccurrencesOfString:@" " withString:@""]];
    unsigned char okm[56];
    [WC_HKDF HKDF_salt:(unsigned char *)[saltData bytes] salt_len:[saltData length] ikm:(const unsigned char *)[ikmData bytes] ikm_len:[ikmData length] info:(const unsigned char *)[infoData bytes] info_len:[infoData length] okm:okm okm_len:56];
    NSData *result = [NSData dataWithBytes:okm length:56];
    LogVerbose(@"%@", result);

    NSData *int32Data = [Varint128 dataWithUInt32:1253];
    LogVerbose(@"%@", int32Data);
}

@end

