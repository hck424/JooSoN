//
//  TableHeaderView.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView
- (void)awakeFromNib {
    [super awakeFromNib];
    _btnTrash.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnTrash.hidden = YES;
}

- (void)setType:(TableHeaderViewType)type {
    _type = type;
    _btnTrash.hidden = YES;
    if (_type == TableHeaderViewTypeDelete) {
        _btnTrash.hidden = NO;
    }
}
- (IBAction)onClickedButtonAction:(UIButton *)sender {
    if (sender == _btnTrash) {
        if (self.onTouchupInsideAction) {
            self.onTouchupInsideAction(_data, 0);
        }
    }
}
@end
