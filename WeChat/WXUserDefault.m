


//
//  WXUserDefault.m
//  WXDemo
//
//  Created by ray on 2018/11/29.
//  Copyright © 2018 ray. All rights reserved.
//

#import "WXUserDefault.h"

#define WXID @"WXID"
#define UIN @"UIN"
#define ALIAS @"ALIAS"
#define NIKENAME @"NIKENAME"
#define CLIENTCHECKDATA @"CLIENTCHECKDATA"
#define LONGLINKIP @"LONGLINKIP"
#define SHORTLINKIP @"SHORTLINKIP"

@implementation WXUserDefault

+ (void)saveWXID:(NSString *)wxid
{
    [[NSUserDefaults standardUserDefaults] setObject:wxid forKey:WXID];
}

+ (NSString *)getWXID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:WXID];
}

+ (void)saveUIN:(NSInteger)uin
{
    [[NSUserDefaults standardUserDefaults] setInteger:uin forKey:UIN];
}

+ (NSInteger)getUIN
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:UIN];
}

+ (void)saveNikeName:(NSString *)nikename
{
    [[NSUserDefaults standardUserDefaults] setObject:nikename forKey:NIKENAME];
}

+ (NSString *)getNikeName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NIKENAME];
}

+ (void)saveAlias:(NSString *)alias
{
    [[NSUserDefaults standardUserDefaults] setObject:alias forKey:ALIAS];
}

+ (NSString *)getAlias
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ALIAS];
}

@end

