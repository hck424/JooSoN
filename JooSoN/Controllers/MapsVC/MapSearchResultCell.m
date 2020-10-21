//
//  MapSearchResultCell.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchResultCell.h"
#import "DBManager.h"
#import "NSString+Utility.h"
#import "UIView+Toast.h"

@interface MapSearchResultCell ()

@property (nonatomic, assign) BOOL onClipPhoneNumber;
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
    
    _btnShare.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnSave.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPresessGesture:)];
    press.minimumPressDuration = 1.0;
    [_btnPhone addGestureRecognizer:press];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configurationData:(PlaceInfo *)info {
    self.info = info;
    self.onClipPhoneNumber = NO;
    _lbTitle.text = info.name;
    _lbAddress.text = info.jibun_address;
    [_btnPhone setAttributedTitle:nil forState:UIControlStateNormal];

    if (_type == MapSearchResultCellDefault) {
        self.btnPhone.hidden = YES;
    }
    else {
        self.btnPhone.hidden = NO;
        if (info.place_id != nil) {
            [DBManager.instance reqeustDetailInfoWithPlaceId:info.place_id userInfo:self.btnPhone success:^(NSDictionary *dataDic) {
                UIButton *targetView = [dataDic objectForKey:@"userInfo"];
                NSDictionary *data = [dataDic objectForKey:@"data"];
                NSString *phonenumber = [data objectForKey:@"formatted_phone_number"];
                if (targetView != nil
                    && data != nil
                    && [targetView isEqual:self.btnPhone]
                    && phonenumber != nil) {
                    
                    targetView.hidden = NO;
                    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:phonenumber attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
                    [self.btnPhone setAttributedTitle:attr forState:UIControlStateNormal];
                    info.phone_number = phonenumber;
                }
                else {
                    //                targetView.hidden = YES;
                }
                [self layoutIfNeeded];
            } fail:^(NSError *error) {
                
            }];
        }
    }
}

- (void)longPresessGesture:(UILongPressGestureRecognizer *)gestrue {
    UIButton *btn = (UIButton *)gestrue.view;
    if (gestrue.state == UIGestureRecognizerStateChanged) {
        NSLog(@"touchdown: %@", btn.titleLabel.text);
        if (_onClipPhoneNumber == NO && btn.titleLabel.attributedText.string != nil) {
            _onClipPhoneNumber = YES;
            [btn.titleLabel.attributedText.string toClipboard];
            NSString *msg = [NSString stringWithFormat:@"%@ 이 복사되었습니다.", btn.titleLabel.attributedText.string];
            [self.contentView makeToast:msg duration:2.0 position:CSToastPositionTop];
        }
    }
    else if (gestrue.state == UIGestureRecognizerStateEnded) {
        _onClipPhoneNumber = NO;
    }
}

- (IBAction)onClickedActions:(UIButton *)sender {
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
    else if (sender == _btnPhone) {
        action = MapCellActionPhone;
    }
    
    if (action >= 0 && self.onTouchUpInSideAction) {
        self.onTouchUpInSideAction(action, _info);
    }
}

@end
