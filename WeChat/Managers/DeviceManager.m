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
@property (nonatomic, strong) WCDevice *huawei6p;
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
        NSString *k19 = @"856AA466-8098-4C90-9D6A-3EF6AFF6BC04"; //k19 = idfv

        NSString *adSource = @"15C0A21B-78A1-4D4C-B7D7-77FEFA23AA35"; //k20 = idfa
        
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
                                                      osType:[@"iOS11.3.1" dataUsingEncoding:NSUTF8StringEncoding]
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
        
        
        /// mi3
        
        NSString *sofyXml3 = @"<softtype>"
        "<lctmoc>0</lctmoc>"
        "<level>1</level>"
        "<k1>ARMv7 Processor rev 1 (v7l) </k1>"
        "<k2>MPSS.DI.4.0-eaa9d90</k2>"
        "<k3>8.1.0</k3>"
        "<k4>865645021226341</k4>"
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
        "<k21>ysh&apos;s MacBook Pro</k21>"
        "<k22></k22>"
        "<k24>02:00:00:00:00:00</k24>"
        "<k26>0</k26>"
        "<k30>&quot;ysh&apos;s MacBook Pro&quot;</k30>"
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
        "<k48>865645021226341</k48>"
        "<k49>/data/user/0/com.tencent.mm/</k49>"
        "<k52>0</k52>"
        "<k53>0</k53>"
        "<k57>1380</k57>"
        "<k58></k58>"
        "<k59>3</k59>"
        "<k60></k60>"
        "<k61>true</k61>"
        "</softtype>";
        
        NSString *guid = @"A097b498fcd5207e";
        NSString *clientSeqId = [NSString stringWithFormat:@"%@_%@", guid, ts];
        NSData *guidData = [[NSString stringWithFormat:@"%@\0", [guid substringWithRange:NSMakeRange(0, 15)]] dataUsingEncoding:NSUTF8StringEncoding];
        WCDevice *mi3 = [[WCDevice alloc] initWithImei:@"865645021226341"
                                              softType:sofytype2
                                             clientSeq:clientSeqId
                                       clientSeqIdsign:@"18c867f0717aa67b2ab7347505ba07ed"
                                            deviceName:@"Xiaomi MI 3W"
                                            deviceType:@"<deviceinfo><MANUFACTURER name=\"Xiaomi\"><MODEL name=\"MI 3W\"><VERSION_RELEASE name=\"8.1.0\"><VERSION_INCREMENTAL name=\"e5e9ee940b\"><DISPLAY name=\"mk_cancro-userdebug 8.1.0 OPM2.171026.006.H1 e5e9ee940b test-keys\"></DISPLAY></VERSION_INCREMENTAL></VERSION_RELEASE></MODEL></MANUFACTURER></deviceinfo>"
                                              language:@"zh_CN"
                                              timeZone:@"8.00"
                                           deviceBrand:@"Xiaomi"
                                                chanel:0
                                           realCountry:@"cn"
                                              bundleID:@""  //ios only
                                             iphoneVer:@""  //ios only
                                                osType:[@"android-27" dataUsingEncoding:NSUTF8StringEncoding]
                                              adSource:@""  //ios only
                                           deviceModel:@"MI 3Warmeabi-v7aarmeabi-v7a"  //ios only
                                              deviceID:guidData];
        
        _mi3 = mi3;
        
        
        /// huawei 6p
        NSString *sofytype4 = @"<softtype><lctmoc>0</lctmoc><level>1</level><k1>0 </k1><k2>angler-03.87</k2><k3>8.1.0</k3><k4>867979021665986</k4><k5></k5><k6></k6><k7>0f2e799e321a92a0</k7><k8>8XV7N16125001121</k8><k9>Nexus 6P</k9><k10>8</k10><k11>Qualcomm Technologies, Inc MSM8994</k11><k12></k12><k13></k13><k14>02:00:00:00:00:00</k14><k15>02:00:00:00:00:00</k15><k16>half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt evtstrm aes pmull sha1 sha2 crc32</k16><k18>18c867f0717aa67b2ab7347505ba07ed</k18><k21>ray&#8217;s Mac Pro</k21><k22></k22><k24>b8:e8:56:29:fd:8c</k24><k26>0</k26><k30>&quot;ray&#8217;s Mac Pro&quot;</k30><k33>com.tencent.mm</k33><k34>google/angler/angler:8.1.0/OPM7.181205.001/5080180:user/release-keys</k34><k35>angler</k35><k36>angler-03.79</k36><k37>google</k37><k38>angler</k38><k39>angler</k39><k40>angler</k40><k41>0</k41><k42>Huawei</k42><k43>null</k43><k44>0</k44><k45></k45><k46></k46><k47>wifi</k47><k48>867979021665986</k48><k49>/data/user/0/com.tencent.mm/</k49><k52>0</k52><k53>0</k53><k57>1460</k57><k58></k58><k59>3</k59><k60></k60><k61>true</k61><k62></k62><k63>A2fba8d86e7d1e66</k63><k64>13b8e25d-ce4f-3caa-a14a-9f4511a25e85</k64></softtype>";
        
        NSString *guid2 = @"A2fba8d86e7d1e6";
        NSString *clientSeqId2 = [NSString stringWithFormat:@"%@_%@", guid2, ts];
        NSData *guidData2 = [[NSString stringWithFormat:@"%@\0", [guid2 substringWithRange:NSMakeRange(0, 15)]] dataUsingEncoding:NSUTF8StringEncoding];
        WCDevice *huawei6p = [[WCDevice alloc] initWithImei:@"867979021665986"
                                              softType:sofytype4
                                             clientSeq:clientSeqId2
                                       clientSeqIdsign:@"18c867f0717aa67b2ab7347505ba07ed"
                                            deviceName:@"Huawei-Nexus 6P"
                                            deviceType:@"<deviceinfo><MANUFACTURER name=\"Huawei\"><MODEL name=\"Nexus 6P\"><VERSION_RELEASE name=\"8.1.0\"><VERSION_INCREMENTAL name=\"d3467592df\"><DISPLAY name=\"lineage_angler-userdebug 8.1.0 OPM7.181205.001 d3467592df\"></DISPLAY></VERSION_INCREMENTAL></VERSION_RELEASE></MODEL></MANUFACTURER></deviceinfo>"
                                              language:@"zh_CN"
                                              timeZone:@"8.00"
                                           deviceBrand:@"google"
                                                chanel:0
                                           realCountry:@"cn"
                                              bundleID:@""  //ios only
                                             iphoneVer:@""  //ios only
                                                osType:[@"android-27" dataUsingEncoding:NSUTF8StringEncoding]
                                              adSource:@""  //ios only
                                           deviceModel:@"Nexus 6Parmeabi-v7a"  //ios only
                                              deviceID:guidData2];
        _huawei6p = huawei6p;
    }

    return self;
}

- (WCDevice *)getCurrentDevice
{
#if PROTOCOL_FOR_IOS
    return _sevenPuls;
#elif PROTOCOL_FOR_ANDROID
    return _huawei6p;
#endif
}


@end
