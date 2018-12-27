//
//  DNSManager.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DNSFetcher.h"
#import "DefaultLongIp.h"
#import "DefaultShortIp.h"
#import "NSString+Regex.h"
#import <Ono.h>

@implementation DNSFetcher

- (void)fetchAndSaveToDB {
    NSURL *url = [NSURL URLWithString:@"http://dns.weixin.qq.com/cgi-bin/micromsg-bin/newgetdns"];
    NSMutableURLRequest *newGetDNSReq = [NSMutableURLRequest requestWithURL:url];
    newGetDNSReq.HTTPMethod = @"GET";
    NSURLSessionTask *task = [[NSURLSession sharedSession]
        dataTaskWithRequest:newGetDNSReq
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:&error];

            NSArray *longLinkIpList = [self getIpListWithDoc:document tag:@"long.weixin.qq.com"];
            NSArray *shortLinkIpList = [self getIpListWithDoc:document tag:@"short.weixin.qq.com"];

            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            for (NSString *longIp in longLinkIpList) {
                if ([longIp isValidIP]) {
                    DefaultLongIp *ip = [[DefaultLongIp alloc] initWithValue:@{@"ip": longIp}];
                    [realm addOrUpdateObject:ip];
                }
            }
            for (NSString *shortIp in shortLinkIpList) {
                if ([shortIp isValidIP]) {
                    DefaultShortIp *ip = [[DefaultShortIp alloc] initWithValue:@{@"ip": shortIp}];
                    [realm addOrUpdateObject:ip];
                }
            }
            [realm commitWriteTransaction];
          }];

    [task resume];
}

- (NSArray<NSString *> *)getIpListWithDoc:(ONOXMLDocument *)document tag:(NSString *)attr {
    NSMutableArray *ma = [NSMutableArray array];

    NSString *path = [NSString stringWithFormat:@"//domain[@name='%@']", attr];
    id<NSFastEnumeration> domainsList = [document XPath:path];

    for (ONOXMLElement *domains in domainsList) {
        for (ONOXMLElement *e in domains.children) {
            NSString *ip = [e stringValue];
            [ma addObject:ip];
        }
    }

    return [ma copy];
}

@end
