//
//  MapSearchView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/09.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchView.h"
#import "UIView+Utility.h"

@interface MapSearchView ()
@property (nonatomic, strong) PlaceInfo *info;
@end


@implementation MapSearchView

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnSave.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _bgView.layer.borderColor = RGB(216, 216, 216).CGColor;
    _bgView.layer.borderWidth = 0.5;
    [_bgView addShadow:CGSizeMake(2, 2) color:RGBA(0, 0, 0, 0.1) radius:1 opacity:0.5];
    [_bgView layoutIfNeeded];
    
}

- (void)configurationData:(PlaceInfo *)info {
    self.info = info;
    
    _lbTitle.text = info.name;
    _lbAddress.text = info.jibun_address;
}
- (IBAction)singleTapGesture:(UITapGestureRecognizer *)sender {
    if ([sender.view isEqual:_svContent]) {
        MapCellAction action = MapCellActionDefault;
        if (self.onTouchUpInSideAction) {
            self.onTouchUpInSideAction(action, _info);
        }
    }
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
