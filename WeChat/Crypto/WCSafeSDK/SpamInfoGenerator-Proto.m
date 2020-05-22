//
//  SpamInfoGenerator-Proto.m
//  WeChat
//
//  Created by ray on 2020/2/28.
//  Copyright © 2020 ray. All rights reserved.
//

#import "SpamInfoGenerator-Proto.h"
#import "NSData+CRC32.h"
#include <sys/time.h>

@implementation SpamInfoGenerator_Proto

+ (NSData *)genST:(int)a {
    ClientSpamInfo *clientSpamInfo = [[DeviceManager sharedManager] getCurrentDevice].clientSpamInfo;
    clientSpamInfo.st.msgLevel = 0; // root
    clientSpamInfo.st.isAdbswitchEnabled = 0; //adb
    
    //过滤包。
    NSMutableArray *installedPackages = clientSpamInfo.st.installedPackageInfosArray;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(InstalledPackageInfo *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject.packageName isEqualToString:@"com.topjohnwu.magisk"] &&
            ![evaluatedObject.packageName isEqualToString:@"org.meowcat.edxposed.manager"] &&
            ![evaluatedObject.packageName isEqualToString:@"com.llb.wechathooks"];
    }];
    NSMutableArray *filteredArray = [[installedPackages filteredArrayUsingPredicate:predicate] mutableCopy];
    clientSpamInfo.st.installedPackageInfosArray = filteredArray;

    //重新计算crc校验数据
    clientSpamInfo.ccdcc = [[clientSpamInfo.st data] crc32];

    return [clientSpamInfo data];
}

static inline int getRandomSpan() {
    return arc4random()%3000 + 201;
}

+ (NSData *)genWCSTFWithAccount:(NSString *)account {
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

    WCSTF *wcstf = [WCSTF new];
    
    GPBUInt64Array *array = [GPBUInt64Array new];
    for (int i=0; i <= account.length; i++) {
       
        [array addValue:(uint32_t)st];
    }
    et = et + timeSpan[arc4random()%20]; // 从此刻向前计算

    wcstf.st = (uint32_t)(ct - 40000);
    wcstf.et = (uint32_t)et;
    wcstf.cc = (uint32_t)array.count;
    wcstf.ctArray = array;
    
    return [wcstf data];
}

+ (NSData *)genWCSTEWithContext:(NSString *)context {
    
    struct timeval tp = {0};
    if (gettimeofday(&tp, NULL) != 0) LogVerbose(@"Error get time");
    
    NSData *wcsteProtoData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mir-WCSTE" ofType:@"bin"]];
    WCSTE *wcste = [WCSTE parseFromData:wcsteProtoData error:nil];
    wcste.st = (uint32_t)tp.tv_sec -1;
    wcste.et = (uint32_t)tp.tv_sec;
    
    return [wcste data];
}

@end
