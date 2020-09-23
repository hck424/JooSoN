//
//  MapSearchResultCell.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchResultCell.h"

@interface MapSearchResultCell ()
@property (nonatomic, strong) PlaceInfo *info;
@end
@implementation MapSearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *selectedBg = [[UIView alloc] init];
    selectedBg.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectedBg;
    _bgView.layer.borderColor = RGB(216, 216, 216).CGColor;
    _bgView.layer.borderWidth = 0.5;
    [_bgView addShadow:CGSizeMake(2, 2) color:RGBA(0, 0, 0, 0.1) radius:1 opacity:0.5];
    
    _btnSave.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configurationData:(PlaceInfo *)info {
    self.info = info;
    _lbTitle.text = info.name;
    _lbAddress.text = info.jibun_address;
}

- (IBAction)onClickedActions:(id)sender {
    MapCellAction action = -1;
    if (sender == _btnSave) {
        action = MapCellActionSave;
    }
    else if (sender == _btnNfc) {
        action = MapCellActionNfc;
    }
    else if (sender == _btnNavi) {
        action = MapCellActionNavi;
    }
    else if (sender == _btnShare) {
        action = MapCellActionShare;
    }
    
    if (action >= 0 && self.onTouchUpInSideAction) {
        self.onTouchUpInSideAction(action, _info);
    }
}

@end
