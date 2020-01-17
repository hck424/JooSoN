//
//  AddPhoneNumberField.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AddPhoneNumberField.h"
@interface AddPhoneNumberField () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;

@end

@implementation AddPhoneNumberField
- (void)awakeFromNib {
    [super awakeFromNib];
    _btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_btnPhoneTitle setTitle:_phoneTitle forState:UIControlStateNormal];
    
}
- (void)setPhoneTitle:(NSString *)phoneTitle {
    _phoneTitle = phoneTitle;
    [self setNeedsDisplay];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(addPhoneNumberFieldTextFieldDidBeginEditing)]) {
        [_delegate addPhoneNumberFieldTextFieldDidBeginEditing];
    }
}
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {
    if ([self.delegate respondsToSelector:@selector(addPhoneNumberFieldTextFieldEdtingChangedString:)]) {
        [_delegate addPhoneNumberFieldTextFieldEdtingChangedString:sender.text];
    }
}

- (IBAction)onClickedButtonAction:(UIButton  *)sender {
    FieldActionType actionType = -100;
    if (sender == _btnPhoneTitle) {
        actionType = FieldActionTypePlus;
    }
    else if (sender == _btnMore) {
        actionType = FieldActionTypeMore;
    }
    else if (sender == _btnDel) {
        actionType = FieldActionTypeDelete;
    }
        
    if (actionType >= 0
        && [self.delegate respondsToSelector:@selector(addPhoneNumberField:action:withObject:)]) {
        [_delegate addPhoneNumberField:self action:actionType withObject:nil];
    }
}

@end
