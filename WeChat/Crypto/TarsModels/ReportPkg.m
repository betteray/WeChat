// **********************************************************************
// This file was generated by a TARS parser!
// TARS version 1.1.0.
// **********************************************************************

#import "ReportPkg.h"

@implementation ReportPkg

@synthesize JV2_PROP_NM(r,0,index);
@synthesize JV2_PROP_NM(o,1,BTu);
@synthesize JV2_PROP_NM(o,2,packageName);
@synthesize JV2_PROP_NM(o,3,signature);
@synthesize JV2_PROP_NM(o,4,fileSize);
@synthesize JV2_PROP_NM(o,5,applicationLabel);
@synthesize JV2_PROP_NM(o,6,versionCode);
@synthesize JV2_PROP_NM(o,7,versionName);
@synthesize JV2_PROP_NM(o,8,appSourceFlag);
@synthesize JV2_PROP_NM(o,9,BTC);
@synthesize JV2_PROP_NM(r,10,BTD);
@synthesize JV2_PROP_NM(o,11,BTE);
@synthesize JV2_PROP_NM(o,12,BTF);
@synthesize JV2_PROP_EX(o,13,BTG,VONSNumber);
@synthesize JV2_PROP_NM(o,14,BTH);
@synthesize JV2_PROP_NM(r,15,BTI);
@synthesize JV2_PROP_NM(o,16,BTJ);
@synthesize JV2_PROP_NM(r,17,BTK);
@synthesize JV2_PROP_NM(o,18,extractPkgCertMd5s);

+ (void)initialize
{
    if (self == [ReportPkg class]) {
        [super initialize];
    }
}

- (id)init
{
    if (self = [super init]) {
        JV2_PROP(packageName) = DefaultTarsString;
        JV2_PROP(applicationLabel) = DefaultTarsString;
        JV2_PROP(versionName) = DefaultTarsString;
        JV2_PROP(BTC) = DefaultTarsString;
        JV2_PROP(BTI) = YES;
    }
    return self;
}

- (void)dealloc
{
    JV2_PROP(packageName) = nil;
    JV2_PROP(signature) = nil;
    JV2_PROP(applicationLabel) = nil;
    JV2_PROP(versionName) = nil;
    JV2_PROP(BTC) = nil;
    JV2_PROP(BTG) = nil;
    JV2_PROP(extractPkgCertMd5s) = nil;
    [super dealloc];
}

+ (NSString*)tarsType
{
    return @"Report.Pkg";
}

@end
