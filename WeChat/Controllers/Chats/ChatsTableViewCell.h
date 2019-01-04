//
//  ChatsTableViewCell.h
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatsTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *avatarImageUrl;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *lastMsg;

@end

NS_ASSUME_NONNULL_END
