//
//  MapSearchCell.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/17.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchCell.h"

@interface MapSearchCell ()
@property (nonatomic, strong) PlaceInfo *info;
@end

@implementation MapSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnSave.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.bgView.layer.borderColor = RGB(216, 216, 216).CGColor;
    self.bgView.layer.borderWidth = 0.5;
    [self.bgView addShadow:CGSizeMake(3, 3) color:RGBA(0, 0, 0, 0.3) radius:3 opacity:0.3];
    [self.bgView layoutIfNeeded];
}

- (void)configurationData:(PlaceInfo *)info {
    self.info = info;
    
    _lbTitle.text = info.name;
    _lbAddress.text = info.jibun_address;
}

- (IBAction)onClickedButtonActions:(id)sender {
    
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
    
    if (action >= 0 && self.onTouchUpInSideAction) {
        self.onTouchUpInSideAction(action, _info);
    }
}

@end
