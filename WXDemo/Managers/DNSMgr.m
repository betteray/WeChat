//
//  DNSMgr.m
//  WXDemo
//
//  Created by ray on 2018/12/4.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DNSMgr.h"
#import <Ono.h>

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

@interface DNSMgr ()

@property (nonatomic, strong) NSArray *longLinkIpList;
@property (nonatomic, strong) NSArray *shortLinkIpList;

@end

@implementation DNSMgr

+ (instancetype)sharedMgr
{
    static DNSMgr *_mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[DNSMgr alloc] init];
    });
    
    return _mgr;
}

- (instancetype)init
{
    self  = [super init];
    if (self) {
        [self getDns];
    }
    return self;
}

- (void)getDns {
    NSURL *url = [NSURL URLWithString:@"http://dns.weixin.qq.com/cgi-bin/micromsg-bin/newgetdns"];
    NSMutableURLRequest *newGetDNSReq = [NSMutableURLRequest requestWithURL:url];
    newGetDNSReq.HTTPMethod = @"GET";
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:newGetDNSReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
        
        NSArray *longLinkIpList = [self getIpListWithDoc:document tag:@"long.weixin.qq.com"];
        NSArray *shortLinkIpList = [self getIpListWithDoc:document tag:@"short.weixin.qq.com"];
        
        self.longLinkIpList = longLinkIpList;
        self.shortLinkIpList = shortLinkIpList;
    }];
    
    [task resume];
}

- (NSArray<NSString* > *)getIpListWithDoc:(ONOXMLDocument *)document tag:(NSString *)attr {
    NSMutableArray *ma = [NSMutableArray array];
    
    NSString *path = [NSString stringWithFormat: @"//domain[@name='%@']", attr];
    id<NSFastEnumeration> domainsList = [document XPath:path];
    
    for (ONOXMLElement *domains in domainsList) {
        for (ONOXMLElement *e in domains.children) {
            NSString *ip = [e  stringValue];
            [ma addObject:ip];
        }
    }
    
    return [ma copy];
}

- (NSString *)getShortLinkIp
{
    return [self.shortLinkIpList randomObject];
}

- (NSString *)getLongLinkIp
{
    return [self.longLinkIpList randomObject];
}

@end
