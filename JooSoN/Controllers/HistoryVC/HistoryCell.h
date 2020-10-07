//
//  HistoryCell.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History+CoreDataProperties.h"
#import "JooSo+CoreDataProperties.h"

typedef enum : NSUInteger {
    HistoryCellActionCall = 0,
    HistoryCellActionSms,
    HistoryCellActionNfc,
    HistoryCellActionNavi,
    HistoryCellActionFace
} HistoryCellAction;

@interface HistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivState;
@property (weak, nonatomic) IBOutlet UILabel *lbCallTime;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbTakeCalling;
@property (weak, nonatomic) IBOutlet UILabel *lbCallCnt;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;
@property (weak, nonatomic) IBOutlet UIButton *btnSms;
@property (weak, nonatomic) IBOutlet UIButton *btnFace;

@property (nonatomic, copy) void (^touchUpInsideBtnAction) (HistoryCellAction action, id data);

- (void)configurationData:(History *)history;
- (void)setTouchUpInsideBtnAction:(void (^)(HistoryCellAction action, id data))touchUpInsideBtnAction;
@end
