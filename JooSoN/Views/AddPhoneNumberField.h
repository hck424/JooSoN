//
//  AddPhoneNumberField.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FieldActionTypePlus = 0,
    FieldActionTypeDelete,
    FieldActionTypeMore
} FieldActionType;

@protocol AddPhoneNumberFieldDelegate <NSObject>

- (void)addPhoneNumberField:(id)field action:(FieldActionType)actionType withObject:(NSString *)object;
- (void)addPhoneNumberFieldTextFieldEdtingChangedString:(NSString *)str;
- (void)addPhoneNumberFieldTextFieldDidBeginEditing;
@end

@interface AddPhoneNumberField : UIView
@property (strong, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneTitle;
@property (assign, nonatomic) BOOL isMainPhone;
@property (nonatomic, strong) NSString *phoneTitle;

@property (nonatomic, weak) id <AddPhoneNumberFieldDelegate>delegate;
@end
