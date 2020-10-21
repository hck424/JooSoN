//
//  TableHeaderView.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    TableHeaderViewTypeDefault,
    TableHeaderViewTypeDelete
}TableHeaderViewType;

@interface TableHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnTrash;
@property (nonatomic, assign) TableHeaderViewType type;
@property (nonatomic, strong) id data;
@property (nonatomic, copy) void (^onTouchupInsideAction) (id data, NSInteger actionIndex);
- (void)setOnTouchupInsideAction:(void (^)(id data, NSInteger actionIndex))onTouchupInsideAction;
@end
