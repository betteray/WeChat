//
//  RAYContactManager.m
//  WeChat
//
//  Created by ysh on 2019/5/23.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RAYContactManager.h"

@interface RAYContactManager ()

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation RAYContactManager

+ (instancetype)sharedManager
{
    static RAYContactManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    
    return mgr;
}

- (void)addContact:(id)contact {
    [self.arr addObject:contact];
}

- (id)findContact:(NSString *)account {
    __block id result = nil;
    [self.arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *account1 = [obj performSelector:@selector(account)];
        if ([account isEqualToString:account1]) {
            *stop = YES;
            result = obj;
        }
    }];
    
    NSLog(@"=====================");
    
    return result;
}

@end
