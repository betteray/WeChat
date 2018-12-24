//
//  DeviceManager.h
//  WeChat
//
//  Created by ray on 2018/12/24.
//  Copyright © 2018 ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCDevice.h"

@interface DeviceManager : NSObject

+ (instancetype)sharedManager;

- (WCDevice *)getCurrentDevice;

@end
