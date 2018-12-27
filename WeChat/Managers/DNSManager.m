//
//  DNSManager.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DNSManager.h"
#import <Ono.h>
#import "DefaultLongIp.h"
#import "DefaultShortIp.h"

@interface NSArray<ObjectType>  (Random)
- (nullable ObjectType)randomObject;
@end

@implementation NSArray (Random)
- (nullable id)randomObject
{
    id randomObject = [self count] ? self[arc4random_uniform((u_int32_t)[self count])] : nil;
    return randomObject;
}
@end

@interface DNSManager ()

@end

@implementation DNSManager

+ (instancetype)sharedMgr
{
    static DNSManager *_mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[DNSManager alloc] init];
    });
    
    return _mgr;
}

- (instancetype)init
{
    self  = [super init];
    if (self) {
        [self fetchDns];
    }
    return self;
}

- (void)fetchDns {
    NSURL *url = [NSURL URLWithString:@"http://dns.weixin.qq.com/cgi-bin/micromsg-bin/newgetdns"];
    NSMutableURLRequest *newGetDNSReq = [NSMutableURLRequest requestWithURL:url];
    newGetDNSReq.HTTPMethod = @"GET";
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:newGetDNSReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
        
        NSArray *longLinkIpList = [self getIpListWithDoc:document tag:@"long.weixin.qq.com"];
        NSArray *shortLinkIpList = [self getIpListWithDoc:document tag:@"short.weixin.qq.com"];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        for (NSString *longIp in longLinkIpList) {
            DefaultLongIp *ip = [[DefaultLongIp alloc] initWithValue:@{@"ip": longIp}];
            [realm addOrUpdateObject:ip];
        }
        for (NSString *shortIp in shortLinkIpList) {
            DefaultShortIp *ip = [[DefaultShortIp alloc] initWithValue:@{@"ip": shortIp}];
            [realm addOrUpdateObject:ip];
        }
        [realm commitWriteTransaction];
        
    }];
    
    [task resume];
}

- (NSArray<NSString* > *)getIpListWithDoc:(ONOXMLDocument *)document tag:(NSString *)attr {
    NSMutableArray *ma = [NSMutableArray array];
    
    NSString *path = [NSString stringWithFormat: @"//domain[@name='%@']", attr];
    id<NSFastEnumeration> domainsList = [document XPath:path];
    
    for (ONOXMLElement *domains in domainsList) {
        for (ONOXMLElement *e in domains.children) {
            NSString *ip = [e stringValue];
            [ma addObject:ip];
        }
    }
    
    return [ma copy];
}

- (NSString *)getShortLinkIp
{
    RLMResults *ips = [DefaultShortIp allObjects];
    NSInteger randomIndex = arc4random() % [ips count];
    return [ips objectAtIndex:randomIndex];
}

- (NSString *)getLongLinkIp
{
    RLMResults *ips = [DefaultLongIp allObjects];
    NSInteger randomIndex = arc4random() % [ips count];
    return [ips objectAtIndex:randomIndex];
}

@end
