//
//  CalSpamAlg.m
//  WeChat
//
//  Created by ray on 2019/9/29.
//  Copyright © 2019 ray. All rights reserved.
//

#import "CalSpamAlg.h"

static char * table[] = {"00", "01","04","05","10","11","14","15","40","41","44","45","50","51","54","55"};

@implementation CalSpamAlg

+ (NSString *)calwcste:(float)f {
    
    int32_t b = *((int32_t *)(&f));
    char buf[16] = {0};
    sprintf(buf, "%08x", b);

    char result[32] = {};
    
    int index = 0;
    for (int i = 0; i < strlen(buf); i++) {
        int v = buf[i];
        if (v < 58) {
            index = v - 48;
        } else {
            index = v - 87;
        }
        
        strcpy(result + 2 * i, table[index]);
    }
    
    return [NSString stringWithFormat:@"%lld", strtoll(result, NULL, 16)];
}

@end
