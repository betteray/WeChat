//
//  DeviceManager.m
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DeviceManager.h"

@interface DeviceManager ()
@property (nonatomic, strong) WCDevice *sevenPuls;
@property (nonatomic, strong) WCDevice *mi3;
@end

@implementation DeviceManager

+ (instancetype)sharedManager
{
    static DeviceManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });

    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *imei = @"8fd2fc510d3fb9bb8e0661b0c6a026cc";
        NSString *ts = [NSString stringWithFormat:@"%ld", (long) [[NSDate date] timeIntervalSince1970]];
        
        //NSString *k19 = @"16F3CF44-DC31-4038-A219-3111C3F71FA8";
        NSString *k19 = @"856AA466-8098-4C90-9D6A-3EF6AFF6BC04";

        NSString *adSource = @"15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35";
        
        NSString *sofyType = [NSString stringWithFormat:@"<softtype>"
                              "<k3>11.3.1</k3>"
                              "<k9>iPhone</k9>"
                              "<k10>2</k10>"
                              "<k19>%@</k19>"
                              "<k20>%@</k20>"
                              "<k22>中国移动</k22>"
                              "<k33>微信</k33>"
                              "<k47>1</k47>"
                              "<k50>1</k50>"
                              "<k51>com.tencent.xin</k51>"
                              "<k54>iPhone9,2</k54>"
                              "<k61>2</k61>"
                              "</softtype>", k19, adSource];
        
        WCDevice *sevenPuls = [[WCDevice alloc] initWithImei:imei
                                                    softType:sofyType
                                                   clientSeq:[NSString stringWithFormat:@"%@-%@", imei, ts]
                                             clientSeqIdsign:@""        // optional for ios
                                                  deviceName:@"cdg iPhone"
                                                  deviceType:@"iPhone"
                                                    language:@"zh_CN"
                                                    timeZone:@"8.00"
                                                 deviceBrand:@"Apple"
                                                      chanel:0
                                                 realCountry:@"CN"
                                                    bundleID:@"com.tencent.xin"
                                                   iphoneVer:@"iPhone9,2"
                                                      osType:@"iOS11.3.1"
                                                    adSource:adSource
                                                 deviceModel:@""
                                                    deviceID:[NSData dataWithHexString:@"49D2FC510D3FB9BB8E0661B0C6A026CC"]];
        

        _sevenPuls = sevenPuls;
        
        NSString *sofytype2 = @"<softtype>"
        "<lctmoc>0</lctmoc>"
        "<level>0</level>"
        "<k1>ARMv7 Processor rev 1 (v7l) </k1>"
        "<k2>MPSS.DI.4.0-eaa9d90</k2>"
        "<k3>8.1.0</k3>"
        "<k4>1234567890ABCDEF</k4>"
        "<k5></k5>"
        "<k6></k6>"
        "<k7>5f27313a5fc898c5</k7>"
        "<k8>b42b493</k8>"
        "<k9>MI 3W</k9>"
        "<k10>4</k10>"
        "<k11>Qualcomm MSM8974PRO-AB</k11>"
        "<k12>0000</k12>"
        "<k13>0000000000000000</k13>"
        "<k14>02:00:00:00:00:00</k14>"
        "<k15>02:00:00:00:00:00</k15>"
        "<k16>swp half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32</k16>"
        "<k18>18c867f0717aa67b2ab7347505ba07ed</k18>"
        "<k21>\"UCFGROUP\"</k21>"
        "<k22></k22>"
        "<k24>70:f9:6d:cb:51:00</k24>"
        "<k26>0</k26>"
        "<k30>\"UCFGROUP\"</k30>"
        "<k33>com.tencent.mm</k33>"
        "<k34>Xiaomi/cancro/cancro:6.0.1/MMB29M/V8.1.6.0.MXDMIDI:user/release-keys</k34>"
        "<k35>MSM8974</k35>"
        "<k36>unknown</k36>"
        "<k37>Xiaomi</k37>"
        "<k38>cancro</k38>"
        "<k39>qcom</k39>"
        "<k40>cancro</k40>"
        "<k41>0</k41>"
        "<k42>Xiaomi</k42>"
        "<k43>null</k43>"
        "<k44>0</k44>"
        "<k45></k45>"
        "<k46></k46>"
        "<k47>wifi</k47>"
        "<k48>1234567890ABCDEF</k48>"
        "<k49>/data/user/0/com.tencent.mm/</k49>"
        "<k52>0</k52>"
        "<k53>0</k53>"
        "<k57>1300</k57>"
        "<k58>0</k58>"
        "<k59>0</k59>"
        "<k61>true</k61>"
        "</softtype>";
        
        NSString *guid = @"A097b498fcd5207e";
        NSString *clientSeqId = [NSString stringWithFormat:@"%@_%@", guid, ts];
        NSData *guidData = [[NSString stringWithFormat:@"%@\0", [guid substringWithRange:NSMakeRange(0, 15)]] dataUsingEncoding:NSUTF8StringEncoding];
        WCDevice *mi3 = [[WCDevice alloc] initWithImei:@"1234567890ABCDEF"
                                              softType:sofytype2
                                             clientSeq:clientSeqId
                                       clientSeqIdsign:@"18c867f0717aa67b2ab7347505ba07ed"
                                            deviceName:@"Xiaomi MI 3Warmeabi-v7a"
                                            deviceType:@"<deviceinfo><MANUFACTURER name=\"Xiaomi\"><MODEL name=\"MI 3W\"><VERSION_RELEASE name=\"8.1.0\"><VERSION_INCREMENTAL name=\"e5e9ee940b\"><DISPLAY name=\"mk_cancro-userdebug 8.1.0 OPM2.171026.006.H1 e5e9ee940b test-keys\"></DISPLAY></VERSION_INCREMENTAL></VERSION_RELEASE></MODEL></MANUFACTURER></deviceinfo>"
                                              language:@"zh_CN"
                                              timeZone:@"8.00"
                                           deviceBrand:@"Xiaomi"
                                                chanel:0
                                           realCountry:@"cn"
                                              bundleID:@""  //ios only
                                             iphoneVer:@""  //ios only
                                                osType:@"android-27"
                                              adSource:@""  //ios only
                                           deviceModel:@"MI 3Warmeabi-v7aarmeabi-v7a"  //ios only
                                              deviceID:guidData];
        
        _mi3 = mi3;
    }

    return self;
}

- (WCDevice *)getCurrentDevice
{
#if PROTOCOL_FOR_IOS
    return _sevenPuls;
#elif PROTOCOL_FOR_ANDROID
    return _mi3;
#endif
}


@end
