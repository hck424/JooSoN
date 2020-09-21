//
//  HAlertView.h
//  Hanpass
//
//  Created by 김학철 on 31/10/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGStackView.h"

IB_DESIGNABLE
typedef enum {
    AlertBtnAlignmentEqual,
    AlertBtnAlignmentRight
} AlertBtnAlignment;

typedef void (^ActionBlock) (NSInteger index);

@interface HAlertView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *btnTitleColors;
@property (nonatomic, strong) NSArray *btnBGColors;
@property (nonatomic, copy) ActionBlock acitonBlock;
@property (nonatomic, assign) AlertBtnAlignment btnAlignment;

@property (nonatomic, assign) NSTextAlignment titleAligment;
@property (nonatomic, assign) CGFloat fontSizeTitle;
@property (nonatomic, strong) UIColor *colorTitle;
@property (nonatomic, assign) CGFloat heightBtn;
@property (nonatomic, assign) UIEdgeInsets titleInset;
@property (nonatomic, assign) UIEdgeInsets textInset;
@property (nonatomic, assign) NSTextAlignment textAligment;
@property (nonatomic, assign) CGFloat fontSizeTextView;
@property (nonatomic, assign) CGFloat fontSizeBtn;
@property (nonatomic, strong) UIColor *colorTextView;

@property (nonatomic, assign) BOOL showNotiUnderLine;
@property (nonatomic, assign) BOOL showUnderLine;

+ (void)alertShowWithTitle:(id)title
                   message:(id)message
              btnTitles:(NSArray *)btnTitles
                alertBlock:(void (^)(NSInteger index))actionBlock;

+ (void)alertShowMsgWithOkAction:(id)message
                alertBlock:(ActionBlock)actionBlock;

+ (void)alertShowMsgWithCancelAndOkAction:(id)message
                     alertBlock:(ActionBlock)actionBlock;


- (instancetype)initWithTitle:(id)title
                      message:(id)message
                    btnTitles:(NSArray *)btnTitles
                   alertBlock:(ActionBlock)actionBlock;


- (void)show;
- (void)dismiss;
@end
