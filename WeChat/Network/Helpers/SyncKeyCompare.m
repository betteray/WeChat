//
//  SyncKeyCompare.m
//  WeChat
//
//  Created by ysh on 2019/1/8.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SyncKeyCompare.h"

@implementation SyncKeyCompare

+ (void)compaireOldSyncKey:(SyncKey *)old newSyncKey:(SyncKey *)new
{
    LogVerbose(@"key count old: %d, new: %d", [old keyCount], [new keyCount]);
    for (KeyVal *okv in [old keyArray]) {
        uint32_t okey = okv.key;
        uint32_t oval = okv.val;
        
        BOOL found = NO;
        for (KeyVal *nkv in [new keyArray]) {
            uint32_t nkey = nkv.key;
            uint32_t nval = nkv.val;
            
            if (okey == nkey) {
                found = YES;
                if (oval == nval) {
//                    LogVerbose(@"kv matched: %@", okv);
                } else {
                    LogVerbose("value not matched: %@, %@", okv, nkv);
                }
            }
        }
        
        if (!found) {
            LogVerbose(@"can't find kv: %@", okv);
        }
    }
}

@end
