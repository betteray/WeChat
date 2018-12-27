//
//  ClientCheckDataFetcher.m
//  WeChat
//
//  Created by ysh on 2018/12/27.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ClientCheckDataFetcher.h"
#import "ClientCheckData.h"

@implementation ClientCheckDataFetcher

- (void)fetchAndSaveToDB {
    NSURL *url = [NSURL URLWithString:@"http://10.12.87.38:8080/"];
    NSMutableURLRequest *newGetDNSReq = [NSMutableURLRequest requestWithURL:url];
    newGetDNSReq.HTTPMethod = @"GET";
    newGetDNSReq.timeoutInterval = 5;
    NSURLSessionTask *task = [[NSURLSession sharedSession]
        dataTaskWithRequest:newGetDNSReq
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (error) {
                LogWarn(@"Get Clinet Check Data Failed: %@", error);
            }
            else {
                LogVerbose(@"Get Clinet Check Data OK.");
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [ClientCheckData createOrUpdateInDefaultRealmWithValue:@[ClientCheckDataID, data]];
                [realm commitWriteTransaction];
            }
          }];

    [task resume];
}

@end
