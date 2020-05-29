//
//  CheckPack.m
//  WeChat
//
//  Created by ray on 2020/5/29.
//  Copyright © 2020 ray. All rights reserved.
//

#import "CheckPack.h"
#import "mmpack.h"

@implementation CheckPack

+ (void)check {
    
    NSArray *testArray = [self loadCheckData];
    
    for (NSDictionary *test in testArray) {
        NSString *method = test[@"method"];
        if ([method isEqualToString:@"MMProtocalJni::packHybridEcdh"]) {
            NSData *cookie = [NSData dataWithHexString:test[@"cookie"]];
            NSData *serilizedData = [NSData dataWithHexString:test[@"AesData"]];
            NSData *result = [NSData dataWithHexString:test[@"result"]];
            
            NSData *packedData =
            [mmpack EncodeHybirdEcdhEncryptPack:[test[@"CGI"] intValue]
                                  serilizedData:serilizedData
                                            uin:[test[@"UIN"] intValue]
                                         cookie:cookie
                                     rsaVersion:[test[@"RsaVer"] intValue]];
            
            LogVerbose(@"test %@ => %@", method, [packedData isEqualToData:result] ? @"pass" : @"fail");
        } else if ([method isEqualToString:@"MMProtocalJni::pack"]) {
            
            NSData *aesKey = [NSData dataWithHexString:test[@"AesKey"]];
            NSData *cookie = [NSData dataWithHexString:test[@"cookie"]];
            NSData *serilizedData = [NSData dataWithHexString:test[@"Data"]];
            NSData *result = [NSData dataWithHexString:test[@"result"]];

            NSData *packedData = [mmpack EncodePack:[test[@"CGI"] intValue]
                                      serilizedData:serilizedData
                                                uin:[test[@"UIN"] intValue]
                                             aesKey:aesKey
                                             cookie:cookie
                                          signature:[test[@"signature"] intValue]
                                               flag:[test[@"flag"] intValue]];
            
            LogVerbose(@"test %@ => %@", method, [packedData isEqualToData:result] ? @"pass" : @"fail");
        } else {
            LogError(@"test %@", method);
        }
    }
}

+ (NSArray *)loadCheckData {
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MMProtocalJni" ofType:@"json"]];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

@end
