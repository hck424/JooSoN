//
//  JooSoCell.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JooSo+CoreDataProperties.h"
#import "Thumnail+CoreDataProperties.h"
typedef enum : NSUInteger {
    CellTypeDefault,
    CellTypeSelect,
    CellTypeClose
} CellType;

typedef enum : NSUInteger {
    CellActionCall = 0,
    CellActionSms,
    CellActionCheck,
    CellActionClose,
    CellActionNfc,
    CellActionNavi
} CellActionType;

@interface JooSoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSms;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;

@property (nonatomic, copy) void (^onBtnTouchUpInside) (CellActionType actionType, JooSo *jooso, id data);
@property (nonatomic, assign) CellType cellType;
- (void)configurationData:(JooSo *)jooso;
- (void)configurationData:(JooSo *)jooso isChecked:(BOOL)isChecked;
- (void)setOnBtnTouchUpInside:(void (^)(CellActionType actionType, JooSo *jooso ,id data))onBtnTouchUpInside;
@end
