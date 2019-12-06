//
//  DBManager.m
//  WeChat
//
//  Created by ray on 2019/12/6.
//  Copyright © 2019 ray. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

+ (AccountInfo *)accountInfo {
    NSPredicate *accountInfoPre = [NSPredicate predicateWithFormat:@"ID = %@", AccountInfoID];
    return [[AccountInfo objectsWithPredicate:accountInfoPre] firstObject];
}

@end
