//
//  WCSafeSDK.m
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import "WCSafeSDK.h"
#import "NSData+CRC32.h"
#import "ASIHTTPRequest.h"
#include <sys/time.h>
#import "FSOpenSSL.h"
#import "TDTZDecompressor.h"
#import "TDTZCompressor.h"

@implementation WCSafeSDK

+ (NSData *)get003FromLocalServer:(NSString *)xml {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://10.20.10.31:8099"]];
    request.postBody = (NSMutableData *)[xml dataUsingEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        LogError(@"Error: %@", error);
        return [NSData new];
    }
    
    return [request responseData];
}

+ (NSString *)genST:(int)a {
    NSString *resName = nil;
    switch (a) {
        case 0:
            resName = @"st-6p-login";
            break;
        case 15:
            resName = @"st-6p-clientcheck";
            break;
        default:
            break;
    }
    
    NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resName ofType:@"bin"]];
    NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdcc>714570694</ccdcc>" withString:@""];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ccdts>1571129457</ccdts>" withString:@""];
    
    NSString *versionXML = [NSString stringWithFormat:@"<ClientVersion>0x%x</ClientVersion>", CLIENT_VERSION];
    xml = [xml stringByReplacingOccurrencesOfString:@"<ClientVersion>0x27000634</ClientVersion>" withString:versionXML];
    
    uint32_t crc32Result = [[xml dataUsingEncoding:NSUTF8StringEncoding] crc32];
    return [NSString stringWithFormat:@"%@<ccdcc>%d</ccdcc><ccdts>%ld</ccdts>", xml, crc32Result, time(0)];
}

+ (void)reportClientCheckWithContext:(uint64_t)context basic:(BOOL)basic
{
    NSString *xml = nil;

    if (basic) {
        xml = [self genBasicST];
    } else {
        xml = [self genST:15];
    }
    NSData *encrypedXMLBuffer = [self get003FromLocalServer:xml];
    
    ReportClientCheckReq *req = [[ReportClientCheckReq alloc] init];
    req.encryptedXmlbuffer = encrypedXMLBuffer;
    req.reportContext = context;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 771;
    cgiWrap.cgiPath = @"/cgi-bin/micromsg-bin/reportclientcheck";
    cgiWrap.request = req;
    cgiWrap.responseClass = [ReportClientCheckResp class];
    cgiWrap.needSetBaseRequest = YES;
    
    [WeChatClient postRequest:cgiWrap success:^(ReportClientCheckResp * _Nullable response) {
        LogVerbose(@"ReportClientCheckResp = %@", response);
    } failure:^(NSError * _Nonnull error) {

    }];
}

static inline int getRandomSpan() {
    return arc4random()%3000 + 201;
}

/**
生成ST(CCData)中的WCSTF字段xml。

@return A xml string.

@discussion Any of the invalid property is ignored.
If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it will also convert the
inner object to json string.
*/
+ (NSString *)genWCSTFWithAccount:(NSString *)account {
    
    // android:inputType="textNoSuggestions" 微信监控 EditText 输入的变化，并且没有这个属性，会因为这个属性导致统计输入的文字个数的不准确，比如myrti_361时，输入_后会多统计一次输入cc=10。
    
    // <WCSTF>
    // <st>1571129265349</st><et>1571129431323</et><cc>10</cc>
    // <ct>1571129265349,1571129265654,1571129269338,1571129269656,1571129269840,1571129274589,1571129274591,1571129275669,1571129276218,1571129276442</ct>
    // </WCSTF>
    
    // <ct>1571129265349,1571129265654,1571129269338,1571129269656,1571129269840,1571129274589,1571129274591,1571129275669,1571129276218,1571129276442</ct>
    //                 305          3684          318            184           4749
    
    int timeSpan[20] =
    {
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(),
        getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan(), getRandomSpan()
    };
    
    struct timeval tp = {0};
    
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    long ct = tp.tv_sec * 1000 + tp.tv_usec ;
    
    long st = ct - 40000 ;
    long et = ct;

    NSMutableString *string = [NSMutableString stringWithString:@"<ct>"];
    for (int i=0; i <= account.length; i++) {
        st = st + timeSpan[arc4random() % 20]; // 从此刻向前计算
        [string appendFormat:@"%ld,", st];
    }
    et = et + timeSpan[arc4random()%20]; // 从此刻向前计算
    
    NSString *ctXML = [string substringToIndex:string.length-1];
    ctXML = [NSString stringWithFormat:@"%@</ct>", ctXML];
    
    return [NSString stringWithFormat:@"<WCSTF><st>%ld</st><et>%ld</et><cc>%ld</cc>%@</WCSTF>", ct - 40000, et, [account length], ctXML];
}

+ (NSString *)genWCSTEWithContext:(NSString *)context {
    
    struct timeval tp = {0};
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    
    return [NSString stringWithFormat:@"<WCSTE><context>%@</context><st>0</st><et>%d</et><iec>0</iec><tec>1</tec><asst>0</asst><pss>384283711954223104</pss><tlmj>1154333283175126352</tlmj><tlmn>1154333283175126352</tlmn><thmj>1154333283175126352</thmj><thmn>1154333283175126352</thmn><sz>382893930598912004</sz></WCSTE>",
    context,
    (int) tp.tv_sec];
}

+ (NSData *)getExtSpamInfoWithContent:(NSString *)content
                                    context:(NSString *)context {
    
    BOOL isAutoAuth = [context containsString:@"auto"];
    WCExtInfo *extInfo = [WCExtInfo new];
    
    if (!isAutoAuth) {
        NSString *WCSTF = [self genWCSTFWithAccount:content];
        NSData *WCSTFData = [self get003FromLocalServer:WCSTF];
        SKBuiltinBuffer_t *wcstf = [SKBuiltinBuffer_t new];
        wcstf.iLen = (int32_t) [WCSTFData length];
        wcstf.buffer = WCSTFData;
        
        extInfo.wcstf = wcstf;
        
        NSString *WCSTE = [self genWCSTEWithContext:context];
        NSData *WCSTEData = [self get003FromLocalServer:WCSTE];
        SKBuiltinBuffer_t *wcste = [SKBuiltinBuffer_t new];
        wcste.iLen = (int32_t) [WCSTEData length];
        wcste.buffer = WCSTEData;
        
        extInfo.wcste = wcste;
    }
    
    NSString *ST = [self genST:0]; // 0 登录用
    NSData *STData = [self get003FromLocalServer:ST];
    SKBuiltinBuffer_t *ccData = [SKBuiltinBuffer_t new];
    ccData.iLen = (int32_t) [STData length];
    ccData.buffer = STData;
    
    extInfo.ccData = ccData;
    
    return [extInfo data];
}

+ (NSString *)genBasicST {
    NSString *loadFiles = @"/system/framework/arm/boot.oat,/system/framework/arm/boot-core-libart.oat,/system/framework/arm/boot-conscrypt.oat,/system/framework/arm/boot-okhttp.oat,/system/framework/arm/boot-bouncycastle.oat,/system/framework/arm/boot-apache-xml.oat,/system/framework/arm/boot-legacy-test.oat,/system/framework/arm/boot-ext.oat,/system/framework/arm/boot-framework.oat,/system/framework/arm/boot-telephony-common.oat,/system/framework/arm/boot-voip-common.oat,/system/framework/arm/boot-ims-common.oat,/system/framework/arm/boot-org.apache.http.legacy.boot.oat,/system/framework/arm/boot-android.hidl.base-V1.0-java.oat,/system/framework/arm/boot-android.hidl.manager-V1.0-java.oat,/data/local/tmp/re.frida.server/frida-agent-32.so,/system/bin/app_process32,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libvoipCodec.so,/data/dalvik-cache/arm/system@app@webview@webview.apk@classes.dex,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libtenpay_utils.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libvoipChannel.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libYTFaceTrackPro.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libalgo_youtu_jni.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libYTCommon.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libdynamicBg.so,/vendor/lib/hw/memtrack.msm8994.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libmmimgcodec.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libaudio_common.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libvoipMain.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libNLog.so,/vendor/lib/hw/android.hardware.memtrack@1.0-impl.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatvoicesilk_v7a.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libimage_filter_gpu.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libkinda_android.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libvoipComm.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatzstd.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libappbrandcommon.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatsight_v7a.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libtxmapengine.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libFFmpeg.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libpitu_tools.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libnnpack.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libformat_convert.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libtencentloc.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatvoicereco.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatpack.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatcommon.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libMMProtocalJni.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libcommonimgdec.so,/system/lib/libqservice.so,/system/lib/libqdutils.so,/system/lib/libmemalloc.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatnormsg.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libhardcoder.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatmm.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libio-canary.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libSqliteLint-lib.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwcdb.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libmatrixmrs.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatCrashForJni.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/oat/arm/base.odex,/dev/ashmem/dalvik-jit-code-cache,/system/lib/libqdMetaData.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libimage_filter_common.so,/vendor/lib/hw/gralloc.msm8994.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libc++_shared.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libwechatxlog.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libstlport_shared.so,/data/app/com.tencent.mm-K01YL1D0BBSmN1t3ThubLw==/lib/arm/libmmkv.so,/data/app/com.llb.wechathooks-bA4onxSecezu3uBx2YWzOA==/oat/arm/base.odex,/system/lib/libsandhook.edxp.so,/system/app/webview/webview.apk,/vendor/lib/libllvm-glnext.so,/system/lib/libwebviewchromium_loader.so,/system/lib/libcompiler_rt.so,/vendor/lib/egl/eglSubDriverAndroid.so,/vendor/lib/egl/libGLESv1_CM_adreno.so,/vendor/lib/egl/libGLESv2_adreno.so,/vendor/lib/egl/libEGL_adreno.so,/vendor/lib/libadreno_utils.so,/vendor/lib/libgsl.so,/system/lib/hw/android.hardware.graphics.mapper@2.0-impl.so,/vendor/lib/hw/android.hardware.graphics.mapper@2.0-impl.so,/system/lib/libjavacrypto.so,/system/lib/libsoundpool.so,/data/dalvik-cache/arm/system@framework@edxp.jar@classes.dex,/system/lib/libvixl-arm.so,/system/lib/libart-dexlayout.so,/system/lib/libvixl-arm64.so,/system/lib/libart-compiler.so,/system/lib/libssl.so,/system/lib/libopenjdkjvm.so,/system/lib/libopenjdk.so,/system/lib/libjavacore.so,/system/lib/libwebviewchromium_plat_support.so,/system/lib/android.hardware.renderscript@1.0.so,/system/lib/libRS.so,/system/lib/libOpenSLES.so,/system/lib/libOpenMAXAL.so,/system/lib/libtextclassifier_hash.so,/system/lib/android.hardware.neuralnetworks@1.0.so,/system/lib/libneuralnetworks.so,/system/lib/libjnigraphics.so,/system/lib/libGLESv3.so,/system/lib/libmediandk.so,/system/lib/libcamera2ndk.so,/system/lib/libmedia_jni.so,/system/lib/libmidi.so,/system/lib/libmtp.so,/system/lib/libexif.so,/system/lib/libaaudio.so,/system/lib/libandroid.so,/system/lib/libmemtrack_real.so,/system/lib/libart.so,/system/lib/liblz4.so,/system/lib/libtombstoned_client.so,/system/lib/libsigchain.so,/system/lib/android.hardware.memtrack@1.0.so,/system/lib/libriru_edxp.so,/system/lib/android.hardware.graphics.mapper@2.0.so,/system/lib/android.hardware.graphics.bufferqueue@1.0.so,/system/lib/libdrmframework.so,/system/lib/android.hardware.configstore@1.0.so,/system/lib/libcamera_client.so,/system/lib/libmediautils.so,/system/lib/libpng.so,/system/lib/libEGL.so,/system/lib/libmemunreachable.so,/system/lib/android.hardware.media.omx@1.0.so,/system/lib/libvulkan.so,/system/lib/liblog.so,/system/lib/libcamera_metadata.so,/system/lib/libui.so,/system/lib/libandroidfw.so,/system/lib/libgui.so,/system/lib/libminikin.so,/system/lib/libhardware.so,/system/lib/libstagefright_xmlparser.so,/system/lib/libnetd_client.so,/system/lib/libsoundtrigger.so,/system/lib/libaudioclient.so,/system/lib/libwilhelm.so,/system/lib/libmedia.so,/system/lib/libappfuse.so,/system/lib/libsensor.so,/system/lib/libnativewindow.so,/system/lib/android.hidl.token@1.0.so,/system/lib/android.hardware.media@1.0.so,/system/lib/libutils.so,/system/lib/libstagefright_http_support.so,/system/lib/libETC1.so,/system/lib/libinput.so,/system/lib/libvorbisidec.so,/system/lib/libmediadrm.so,/system/lib/libbase.so,/system/lib/libbacktrace.so,/system/lib/libicui18n.so,/system/lib/libmemtrack.so,/system/lib/libdebuggerd_client.so,/system/lib/libcrypto.so,/system/lib/libsqlite.so,/system/lib/libpackagelistparser.so,/system/lib/libpcre2.so,/system/lib/libtinyxml2.so,/system/lib/libstagefright_flacdec.so,/system/lib/libRScpp.so,/system/lib/libnativebridge.so,/system/lib/liblzma.so,/system/lib/libz.so,/system/lib/libdl.so,/system/lib/libselinux.so,/system/lib/android.hidl.token@1.0-utils.so,/system/lib/libft2.so,/system/lib/libmedia_helper.so,/system/lib/libcutils.so,/system/lib/libimg_utils.so,/system/lib/libziparchive.so,/system/lib/libbinder.so,/system/lib/libicuuc.so,/system/lib/libsonivox.so,/system/lib/libnativehelper.so,/system/lib/libGLESv2.so,/system/lib/android.hidl.memory@1.0.so,/system/lib/libmedia_omx.so,/system/lib/android.hardware.configstore-utils.so,/system/lib/libpdfium.so,/system/lib/libnativeloader.so,/system/lib/libstdc++.so,/system/lib/libc.so,/system/lib/libprotobuf-cpp-lite.so,/system/lib/libstagefright_omx_utils.so,/system/lib/libskia.so,/system/lib/libm.so,/system/lib/libusbhost.so,/system/lib/libvndksupport.so,/system/lib/libhwui.so,/system/lib/libgraphicsenv.so,/system/lib/libstagefright_foundation.so,/system/lib/libharfbuzz_ng.so,/system/lib/libvintf.so,/system/lib/libdng_sdk.so,/system/lib/libGLESv1_CM.so,/system/lib/libstagefright.so,/system/lib/libhardware_legacy.so,/system/lib/libmediametrics.so,/system/lib/android.hidl.allocator@1.0.so,/system/lib/libsync.so,/system/lib/libpowermanager.so,/system/lib/android.hardware.drm@1.0.so,/system/lib/libaudioutils.so,/system/lib/libhidlmemory.so,/system/lib/libunwind.so,/system/lib/libspeexresampler.so,/system/lib/libandroid_runtime.so,/system/lib/libpiex.so,/system/lib/libhwbinder.so,/system/lib/android.hardware.cas@1.0.so,/system/lib/libaudiomanager.so,/system/lib/libjpeg.so,/system/lib/libprocessgroup.so,/system/lib/libc++.so,/system/lib/android.hardware.graphics.common@1.0.so,/system/lib/android.hardware.graphics.allocator@2.0.so,/system/lib/android.hardware.cas.native@1.0.so,/system/lib/libhidlbase.so,/system/lib/libheif.so,/system/lib/libexpat.so,/system/lib/libhidltransport.so,/system/bin/linker";
    TDTZCompressor *compressor = [[TDTZCompressor alloc] initWithCompressionFormat:TDTCompressionFormatDeflate level:9];
    NSData *compressedData = [compressor finishData:[loadFiles dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *base64Str = [FSOpenSSL base64FromData:compressedData encodeWithNewlines:NO];
   
    return [NSString stringWithFormat:@"<st><Manufacturer>Huawei</Manufacturer><Model>Nexus 6P</Model><VersionRelease>8.1.0</VersionRelease><VersionIncremental>d3467592df</VersionIncremental><Display>lineage_angler-userdebug 8.1.0 OPM7.181205.001 d3467592df</Display><FingerPrint>google/angler/angler:8.1.0/OPM7.181205.001/5080180:user/release-keys</FingerPrint><NDM>%@</NDM></st>", base64Str];
    
}

+ (void)decodeNDM {
    NSString *base64Str = @"eNqtWm1z2zYM/kGr5Sbpbe2H3iVNX+62pN0tuW39pKMoWGLMt5KUbOfXD5Ts1I5B25n0IZc7EgJB4AHwgMnUr3wANZ05pmBh3HzKnJoWxoTMsPBqmtyecONgIkXB3Ami2nO3skcFzbwOwR6TKkyj+YozHyQck2WW8RomSyWPSUqoGF9NAvijZsLyqMjT0jHBABJsbfQKvaSU0cfkWyPsiaJC+RMljauy3lNZF4DeF9kpMGC6dEaUWS1KmRXMw+Tvs+z15IG17EWfKqZZBS7xdSH0lFmbW2c4eH9x/mpassDi2hSvmAXQHHTIlJr88frs+83Zx9cfPtypr2fh4r5uipvF+/dTxGp3Nv6OTrw2JfDMm2GaypVmSvAP1U9NJZOtmE94dGcn1t/hEk+4XEDRClhsfqPT55dcMu/BZyUsh9milFAVH+VarCmFydfgGapMa4TWfLCa7/efGYd7h7r+dGawuplxigW8o24BS9hQdUIhfPOZkAFcXtlmhOtej+P+HctGCmmXQDXTGuQoum6ZGG7UAnjNAqrDEiHkPG9/Y4N1orhlq7wJQvrByr7emGqwEitCkwdjRrCHycrkK9OgwgctBqubC12yfFPVR4EYonUkWDz6MNwm/KxweMGRsqi3zIuqDqOAdSsBHPDhJTIsFbOgK6FhjESK4tLwka45Sk/5/FlZGJ6Tt7fYkYLhTP4+Qh719xsJY70aJAYbWrBmVFEkcgZQTG6C0oIujeu26sW0cv2O8urtu3dviI9/lLcQ2Ee0jtz8WTSf7XhwLWJ0JEdpbOR+eAxr5spIntxIZo1QuYRBFqmZWw3WdPdDigA3Qoc4sg2/IS+HK0H25cRSOT+Sw68d8/Vn4/53CuLA0Q8nOMVkZjAd761ayhF6Pv/ll9wjQGHdwqCd4l0xdzfDxoOIU3YJ/dQxdIyYt4MtxtncGhd2rN5WJ2WR9Q6qjZn7SXH1xujlHXB4bC6aD8vz7/88fruig7JbTTz246gjg3Jpt6tNPGo9Z0235q3n36+3eO2MEo3KpWGbIrAriGZbIZFDr6eFrWoJlYw/d03x0QkcJ662ONAzMfz95ebTXXuWX9/mrHSgzSGx84QM/kjZqkkldXyN2N+tvCRWe2VbdHb/2E9fbrbP3PIB9oSnkR2L5QIjm2GTsLXgHud3a8FdnuP0LpSVRD952be7vo8PAt0LkiE2vWl0aZERH5/Bn14hLju0PDC3O37vKmYuZlUfdeLcVizlBJUTW/FLVChZZNcHPv2VaqsGOddDOU/vPLTUmd4nPWccEFvPkW8lzsO+sTFxCfG/7p4v7kUUUYO547kTNlyeZa8JLd/wCneI7MTW7dW/VzdHz9HQIDnREGIofeKkXSFCIGDmdNEXM4FpXWNJpRyoxRNQ93e7JL0giVUp0G4qikqUgloOlliFpZhRxQhx7Nh54oB49tNI9wyZ3dMOtbFVs/Y4YoivLrkDRkFMPlIoDkZhFzAaypxLEVsHmSYUkEWFjWH9IHAIBhvDEgBwwjX5866w479cIX8taf76dEoi6LGAU8aHErs15UViTWi7Xx72rsmNnokKfelgkuLUPrAKZq4bJeMT7oE8LtBj0W3UzTpwrJ9iKZ+IUqLTzZqRHjSakXl5ShOgDl6gr+i23LdJsi1o0ZolFXzSi3umlU697ApFM5uB+9FAAwlIJntYvWiobCUXSyiaCgN0ILFaLAxpBJS6yv2BylGDtKSvbZxy8ZYTbu0kThRJ33RP+h1SktU5HLD/kYqnBVg68AwpAmmdElrM98tGn8uzonl8zHWVQHVHL4kLcwfnB4pDvv5LCZVlpMK1g2YLKmjGFcILYlDfcWs3lTOsBgnPWgEk6Im1isRXB4JUoekqBB03oj6jooSVbSPnTB+pZEYt85QhD5uHmz2Ixr8QVc40VN3f5Croljp7pTnJ1nSYHTaVQjgLOAukx4m+AyVTwJJYLSXJzDAfKZQCyR2Q4R8EWDBz0DFsyW4ThF4tlTw/TU0KYth8Hc2qGr3Ack9SDcVS6igfYqvDEEnhg2XO03Ggu/WaWlDuu78+O4Jb9E3yvL7EIrIpHXPyGj2SokvM4iVsIeH8ZCsVvGk4yUEtC7STGo2kENlaIYFWKM7e6uSVko1GqCqZ+LNwnlSInK+sIDUjItwqmth4xIhuqJAshEQr1Wm1LsOwJpyOFccb8ugfVCON4C1nOJWdzj5+9gWaQ62/zF2jg1DUiY0vauNDCrQlOeri6s9/djicFrMYBIyToRDxKDBleI1BPP3K/eN2wuOxCGEOa59gQcg3Z41PsuAU/FLrm3e+A9eXjB9q7lvUOevhnOrwZgGOYOnxvyQQx3Nw/wEhRQTU";

    NSData *data = [FSOpenSSL base64decodeFromString:base64Str];
    
    TDTZDecompressor *decompressor = [[TDTZDecompressor alloc] initWithCompressionFormat:TDTCompressionFormatDeflate];
    data = [decompressor finishData:data];
    
    NSString *NDM = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    LogVerbose(@"%@", NDM);
}

@end
