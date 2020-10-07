//
//  HistoryCell.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "HistoryCell.h"
#import "NBAsYouTypeFormatter.h"
#import "NSString+Utility.h"


@interface HistoryCell ()
@property (nonatomic, strong) History *history;
@property (nonatomic, strong) NBAsYouTypeFormatter *nbaFomater;
@property (nonatomic, strong) NSDateFormatter *df;
@end

@implementation HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nbaFomater = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"KR"];
    self.df = [[NSDateFormatter alloc] init];
    _df.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    _btnNfc.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnNavi.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnCall.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnSms.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
 
}

- (void)configurationData:(History *)history {
    self.history = history;
    
    _df.dateFormat = @"HH:mm";
    NSString *timeStr = [_df stringFromDate:_history.createDate];
    _lbCallTime.text = timeStr;
    _lbCallCnt.hidden = YES;
    _lbTakeCalling.hidden = YES;
    
    _btnCall.hidden = YES;
    _btnNfc.hidden = YES;
    _btnNavi.hidden = YES;
    _btnSms.hidden = YES;
    _btnFace.hidden = YES;

    _btnCall.enabled = NO;
    _btnNfc.enabled = NO;
    _btnNavi.enabled = NO;
    _btnSms.enabled = NO;
    _btnFace.enabled = NO;

    
    NSString *imgName = @"";
    //historytype =? 0: 전화타입, 1: sms, 2: facephone, 3: nfc, 4: navi
    if (_history.historyType == 0) {
        if (_history.name.length > 0) {
            _lbName.text = _history.name;
        }
        else {
            NSString *phoneNumber = _history.phoneNumber;
            phoneNumber = [phoneNumber delPhoneFormater];
            _lbName.text = [_nbaFomater inputString:phoneNumber];
        }
        NSString *callType = _history.callType; //1: 전화, 2: face type;
        NSString *callState = _history.callState;
        
        /*!
         callState
         0 : 아무것도 아닌상태
         1 : 부재중,
         2: 내가걸고 통화하지 않고 끈은것,
         3: 들어온 전화 통화하지 않고 끊은것,
         4: 내가 전화 걸어 성공후 통화 종료
         5: 들어온 전화 받고 통화 종료
         */
        
        
        //        historytype =? 0: 전화타입, 1: sms, 2: facephone, 3: nfc, 4: navi
        _ivState.image = [UIImage imageNamed:imgName];
        
        if ([callType isEqualToString:@"1"]) {
            if ([callState isEqualToString:@"1"]
                || [callState isEqualToString:@"2"]
                || [callState isEqualToString:@"3"]) {
                imgName = @"call_type1_b";
            }
            else if ([callState isEqualToString:@"4"]) {
                imgName = @"call_type1_s";
            }
            else if ([callState isEqualToString:@"5"]) {
                imgName = @"call_type1_r";
            }
            else {
                imgName = @"call_type1_a";
            }
        }
        else {
            if ([callState isEqualToString:@"4"]) {
                imgName = @"call_type2_s";
            }
            else if ([callState isEqualToString:@"5"]) {
                imgName = @"call_type2_r";
            }
            else {
                imgName = @"icon_videocall_d";
            }
        }
        
        _lbCallCnt.textColor = RGB(38, 38, 38);
        _lbName.textColor = RGB(38, 38, 38);
        
        if (_history.callCnt > 0) {
            _lbCallCnt.hidden = NO;
            _lbCallCnt.text = [NSString stringWithFormat:@"(%ld)", (long)_history.callCnt];
            if ([callState isEqualToString:@"1"]) {
                _lbCallCnt.textColor = RGB(255, 0, 0);
                _lbName.textColor = RGB(255, 0, 0);
            }
        }
        
        _lbTakeCalling.hidden = YES;
        if (_history.takeCalling > 0
            && ([callState isEqualToString:@"4"]
                || [callState isEqualToString:@"5"])) {
            _lbTakeCalling.hidden = NO;
            _lbTakeCalling.text = [NSString stringWithFormat:@"%@", [self getMiliSecond]];
        }
       
        _ivState.image = [UIImage imageNamed:imgName];
        
        _btnCall.hidden = NO;
        _btnCall.enabled = YES;
    }
    else if (_history.historyType == 1) {  //sms
        imgName = @"call_icon2_p";
        _ivState.image = [UIImage imageNamed:imgName];
        
        if (_history.name.length > 0) {
            _lbName.text = _history.name;
        }
        else {
            NSString *phoneNumber = _history.phoneNumber;
            phoneNumber = [phoneNumber delPhoneFormater];
            _lbName.text = [_nbaFomater inputString:phoneNumber];
        }
        _btnSms.hidden = NO;
        _btnSms.enabled = YES;
        
    }
    else if (_history.historyType == 2) { // face
        imgName = @"call_icon3_p";
        if (_history.name.length > 0) {
            _lbName.text = _history.name;
        }
        else {
            NSString *phoneNumber = _history.phoneNumber;
            phoneNumber = [phoneNumber delPhoneFormater];
            _lbName.text = [_nbaFomater inputString:phoneNumber];
        }
        _ivState.image = [UIImage imageNamed:imgName];
        _btnFace.hidden = NO;
        _btnFace.enabled = YES;
    }
    else if (_history.historyType == 3) { // nfc
        imgName = @"call_icon7_p";
        _lbName.text = _history.address;
        _ivState.image = [UIImage imageNamed:imgName];
        _btnNfc.hidden = NO;
        _btnNfc.enabled = YES;
    }
    else {      //navi
        imgName = @"call_icon8_p";
        _lbName.text = _history.address;
        _ivState.image = [UIImage imageNamed:imgName];
        _btnNavi.hidden = NO;
        _btnNavi.enabled = YES;
    }
}
- (NSString *)getMiliSecond {
    NSInteger ti = ceil(_history.takeCalling * 10);
    NSInteger second = ti/10;
    NSInteger ms = ti%10;
    NSInteger mi = 0;
    NSString *result = nil;
    if (second < 60) {
        result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",mi, second, ms];
    }
    else {
        mi = second/60;
        second = second%60;
        result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", mi, second, ms];
    }
    
    return result;
}

- (IBAction)onClickedButtonAction:(id)sender {
    HistoryCellAction action = -1;
    
    if (sender == _btnCall) {
        action = HistoryCellActionCall;
    }
    else if (sender == _btnSms) {
        action = HistoryCellActionSms;
    }
    else if (sender == _btnNavi) {
        action = HistoryCellActionNavi;
    }
    else if (sender == _btnNfc) {
        action = HistoryCellActionNfc;
    }
    else if (sender == _btnFace) {
        action = HistoryCellActionFace;
    }
    
    if (self.touchUpInsideBtnAction && action >= 0) {
        self.touchUpInsideBtnAction(action, _history);
    }
}

@end
