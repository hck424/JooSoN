//
//  GroupCell.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "GroupCell.h"
@interface GroupCell ()
@property (nonatomic, strong) GroupName *group;
@end
@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnCount.layer.cornerRadius = _btnCount.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configurationData:(GroupName *)group {
    self.group = group;
    NSString *title = [NSString stringWithFormat:@"%lld 명", _group.count];
    [_btnCount setTitle:title forState:UIControlStateNormal];
    _lbTitle.text = group.name;
}
- (IBAction)onClickedAction:(UIButton *)sender {
    if (sender == _btnDel) {
        if (self.touchUpInsideAction) {
            self.touchUpInsideAction(0, _group);
        }
    }
}
@end
