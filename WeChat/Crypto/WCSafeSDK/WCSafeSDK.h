//
//  WCSafeSDK.h
//  WeChat
//
//  Created by ray on 2019/10/15.
//  Copyright © 2019 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WCSafeSDKDataFormat) {
    WCSafeSDKDataFormatXML,
    WCSafeSDKDataFormatProto
};

@interface WCSafeSDK : NSObject

//&lt;LoginByID&gt
+ (NSData *)getExtSpamInfoWithContent:(NSString *)content
                              context:(NSString *)context
                               format:(WCSafeSDKDataFormat)format;


@end

NS_ASSUME_NONNULL_END
