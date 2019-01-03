//
//  WCMessage.h
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import "RLMObject.h"


@interface WCMessage : RLMObject

@property NSInteger newMsgId; //每条消息的唯一id
@property NSString * fromUserName; //发送方wxid
@property NSString * toUserName; //接收方wxid
@property NSInteger msgType; //消息类型:9999==>系统垃圾消息,10002==>sysmsg(系统垃圾消息),49==>appmsg,1==>文字消息,10000==>系统提示
@property NSString * content; //原始消息内容,需要根据不同消息类型解析
@property NSInteger createTime;  //消息发送时间

@end

