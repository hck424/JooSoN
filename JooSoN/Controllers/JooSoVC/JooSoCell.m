//
//  JooSoCell.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "JooSoCell.h"
#import "JooSo+CoreDataProperties.h"
@interface JooSoCell ()
@property (nonatomic, strong) JooSo *jooso;
@property (nonatomic, assign) BOOL isChecked;


@end
@implementation JooSoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnCall.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnSms.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnCheck.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnClose.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = RGBA(243, 243, 243, 1);
    self.selectedBackgroundView = selectedView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configurationData:(JooSo *)jooso isChecked:(BOOL)isChecked {
    self.isChecked = isChecked;
    [self configurationData:jooso];
}
- (void)configurationData:(JooSo *)jooso {
    self.jooso = jooso;

    _btnSms.hidden = YES;
    _btnCall.hidden = YES;
    _btnCheck.hidden = YES;
    _btnClose.hidden = YES;
    _btnNavi.hidden = YES;
    _btnNfc.hidden = YES;
    
    _ivProfile.layer.cornerRadius = _ivProfile.frame.size.height/2;
    _ivProfile.layer.borderColor = RGB(224, 224, 224).CGColor;
    _ivProfile.layer.borderWidth = 1.0f;
    
    if (_cellType == CellTypeSelect) {
        _btnCheck.hidden = NO;
    }
    else if (_cellType == CellTypeClose) {
        _btnClose.hidden = NO;
    }
    else {
        _btnCall.hidden = NO;
        _btnSms.hidden = NO;
        
        if ((_jooso.address.length > 0 || _jooso.roadAddress.length > 0) && _jooso.geoLng > 0 && jooso.geoLng > 0) {
//            _btnNavi.hidden = NO;
//            _btnNfc.hidden = NO;
            _ivProfile.layer.borderColor = RGB(36, 183, 179).CGColor;
            
        }
    }
    
    _btnCall.enabled = YES;
    _btnSms.enabled = YES;
    
    if ([_jooso getMainPhone].length == 0) {
        _btnCall.enabled = NO;
        _btnSms.enabled = NO;
    }
    
    _btnCheck.selected = self.isChecked;
    _lbName.text = _jooso.name;

    if (_jooso.toThumnail.image) {
        _ivProfile.image = (UIImage *)_jooso.toThumnail.image;
    }
    else {
        _ivProfile.image = [UIImage imageNamed:@"icon_profile_people_s"];
    }
}

- (IBAction)onClickedButtonAction:(UIButton *)sender {
    
    CellActionType action = -1;
    if (sender == _btnCall) {
        action = CellActionCall;
    }
    else if (sender == _btnSms) {
        action = CellActionSms;
    }
    else if (sender == _btnCheck) {
        sender.selected = !sender.selected;
        action = CellActionCheck;
    }
    else if (sender == _btnClose) {
        action = CellActionClose;
    }
    else if (sender == _btnNfc) {
        action = CellActionNfc;
    }
    else if (sender == _btnNavi) {
        action = CellActionNavi;
    }
    
    if (action >= 0 && self.onBtnTouchUpInside) {
        self.onBtnTouchUpInside(action, _jooso, nil);
    }
}


@end
