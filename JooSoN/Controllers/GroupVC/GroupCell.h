//
//  GroupCell.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupName+CoreDataProperties.h"
NS_ASSUME_NONNULL_BEGIN

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UIButton *btnCount;
@property (nonatomic, copy) void (^touchUpInsideAction) (NSInteger btnIndex, id data);
- (void)configurationData:(GroupName *)group;

- (void)setTouchUpInsideAction:(void (^ _Nonnull)(NSInteger btnIndex, id _Nonnull data))TouchUpInsideAction;
@end

NS_ASSUME_NONNULL_END
