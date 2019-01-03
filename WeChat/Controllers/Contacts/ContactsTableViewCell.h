//
//  ContactsTableViewCell.h
//  WeChat
//
//  Created by ysh on 2019/1/3.
//  Copyright © 2019 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *nickName;

@end

NS_ASSUME_NONNULL_END
