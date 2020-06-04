//
//  CdnTask.h
//  WeChat
//
//  Created by ray on 2020/6/2.
//  Copyright © 2020 ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessBlock)(id _Nullable response);
typedef void (^FailureBlock)(NSError *error);

@interface CdnTask : NSObject

@property (nonatomic, strong, readonly) NSMutableData *head;
@property (nonatomic, strong, readonly) NSMutableData *body;
@property (nonatomic, assign, readonly) NSUInteger seq;
@property (nonatomic, assign) BOOL hasPacket;

- (instancetype)initWithSeq:(NSUInteger)seq;

- (void)packBody;
- (void)packHead;

- (NSString *)getIp;
- (CDNDnsInfo *)getDnsInfo;

- (void)writeField:(NSString *)field WithValue:(id)value;

- (void)startCdnRequestSuccess:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;


// for test only;
- (NSDictionary *)parseResponseToDic:(NSData *)cdnPacketData;
@end

NS_ASSUME_NONNULL_END
