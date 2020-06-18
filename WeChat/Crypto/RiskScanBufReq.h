//
//  RiskScanBufReq.h
//  WeChat
//
//  Created by ray on 2019/10/18.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ReportUserInfo;
@class ReportReq;
@class ReportPhoneType;

@interface RiskScanBufReq : NSObject

+ (void)test;
+ (NSString *)getRiskScanBufReq:(ReportUserInfo *)userInfo req:(ReportReq *)req phoneType:(ReportPhoneType *)phoneType;

@end

NS_ASSUME_NONNULL_END
