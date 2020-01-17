//
//  HAlertView.m
//  Hanpass
//
//  Created by 김학철 on 31/10/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import "HAlertView.h"
#import "CTextView.h"
#import "UIView+Utility.h"

#define DEFAULT_HEIGHT_BTN 50
#define DEFAULT_FONT_TITLE  18
#define DEFAULT_FONT_TEXTVIEW 17
#define DEFAULT_FONT_BTN 17

#define DEFAULT_COLOR_TITLE RGB(255, 255, 255)
#define DEFAULT_COLOR_TEXTVIEW RGB(84, 84, 84)
#define DEFAULT_COLOR_GRAY RGB(84, 84, 84)
#define DEFAULT_GREEN_COLOR RGB(82, 167, 163)
#define DEFAULT_WHITE_COLOR RGB(255, 255, 255)

#define Tag_View 908090

@interface HAlertView ()
@property (nonatomic, strong) id title;
@property (nonatomic, strong) id message;
@property (nonatomic, strong) NSArray *btnTitles;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIStackView *svTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIView *topUnderLine;

@property (weak, nonatomic) IBOutlet UIStackView *svContent;
@property (weak, nonatomic) IBOutlet CTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightSvButton;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIStackView *svButton;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, assign) CGFloat minHeightTextView;

@end

@implementation HAlertView

+ (void)alertShowMsgWithOkAction:(id)message
                      alertBlock:(ActionBlock)actionBlock {
    
    NSString *strOk = NSLocalizedString(@"str_popup_title_done", @"");
    HAlertView *alert = [[HAlertView alloc] initWithTitle:nil
                                                  message:message
                                                btnTitles:@[strOk]
                                               alertBlock:actionBlock];
    
    alert.btnBGColors = @[DEFAULT_WHITE_COLOR];
    alert.btnTitleColors = @[[UIColor whiteColor]];
    alert.textInset = UIEdgeInsetsMake(20, 16, 16, 16);
    [alert show];
}

+ (void)alertShowMsgWithCancelAndOkAction:(id)message
                               alertBlock:(ActionBlock)actionBlock {
    
    NSString *strOk = NSLocalizedString(@"str_popup_title_done", @"");
    NSString *strCancel = NSLocalizedString(@"str_popup_title_cancel", @"");
    HAlertView *alert = [[HAlertView alloc] initWithTitle:nil
                                                  message:message
                                                btnTitles:@[strCancel, strOk]
                                               alertBlock:actionBlock];
    
    alert.btnBGColors = @[DEFAULT_WHITE_COLOR, DEFAULT_WHITE_COLOR];
    alert.btnTitleColors = @[DEFAULT_GREEN_COLOR, DEFAULT_COLOR_GRAY];
    alert.textInset = UIEdgeInsetsMake(20, 16, 16, 16);
    [alert show];
}

+ (void)alertShowWithTitle:(id)title
                   message:(id)message
              btnTitles:(NSArray *)btnTitles
                alertBlock:(ActionBlock)actionBlock {
    
    
    HAlertView *alert = [[HAlertView alloc] initWithTitle:title
                                                  message:message
                                                btnTitles:btnTitles
                                               alertBlock:actionBlock];
    alert.btnBGColors = @[DEFAULT_WHITE_COLOR, DEFAULT_WHITE_COLOR];
    alert.btnTitleColors = @[DEFAULT_GREEN_COLOR, DEFAULT_COLOR_GRAY];
    alert.textInset = UIEdgeInsetsMake(20, 16, 20, 16);
    [alert show];
}

- (instancetype)initWithTitle:(id)title
                       message:(id)message
                  btnTitles:(NSArray *)btnTitles
                    alertBlock:(ActionBlock)actionBlock {
    
    if (self = [self initWithFrame:[UIScreen mainScreen].bounds]) {
        
        //default setting
        _titleAligment = NSTextAlignmentCenter;
        _textAligment = NSTextAlignmentCenter;
        _fontSizeTitle = DEFAULT_FONT_TITLE;
        _fontSizeBtn = DEFAULT_FONT_BTN;
        _fontSizeTextView = DEFAULT_FONT_TEXTVIEW;
        _showNotiUnderLine = NO;
        _showUnderLine = NO;
        _btnAlignment = AlertBtnAlignmentEqual;
        _heightBtn = DEFAULT_HEIGHT_BTN;
        _colorTitle = DEFAULT_COLOR_TITLE;
        _colorTextView = DEFAULT_COLOR_TEXTVIEW;
        _titleInset = UIEdgeInsetsMake(20, 16, 20, 16);
        _textInset = UIEdgeInsetsMake(10, 16, 10, 16);
        
        self.title = title;
        self.message = message;
        self.btnTitles = btnTitles;
        
        self.minHeightTextView = 80.0f;
        self.acitonBlock = actionBlock;
        [self loadXib];
    }
    return self;
}

- (void)loadXib {
    self.bgView = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"HAlertView" owner:self options:nil].firstObject;
    _bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bgView];
    
    [_bgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0].active = YES;
    [_bgView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = YES;
    [_bgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0].active = YES;
    [_bgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0].active = YES;
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
}

- (void)configurationUI {
    [self layoutIfNeeded];
    [_shadowView addShadow:CGSizeMake(3, 3) color:RGBA(0, 0, 0, 0.5) radius:5 opacity:0.5];
    [_containerView roundCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:20];
    
    _svTitle.hidden = YES;
    _topUnderLine.hidden = YES;
    
    if (_title != nil) {
        _svTitle.hidden = NO;
        
        if ([_title isKindOfClass:[NSAttributedString class]]) {
            _lbTitle.attributedText = _title;
        }
        else {
            _lbTitle.text = _title;
        }
        
        _lbTitle.font = [UIFont systemFontOfSize:_fontSizeTitle weight:UIFontWeightMedium];
        _lbTitle.textAlignment = _titleAligment;
        
        _lbTitle.textColor = _colorTitle;
        
        [_svTitle setLayoutMarginsRelativeArrangement:YES];
        _svTitle.layoutMargins = _titleInset;
        if (_showUnderLine) {
            _topUnderLine.hidden = NO;
        }
    }
    
    _textView.hidden = NO;
    _textView.backgroundColor = [UIColor whiteColor];
    if (_contentView != nil) {
        _textView.hidden = YES;
    
        [_svContent addArrangedSubview:_contentView];
    }
    else {
        
        _textView.textColor = _colorTextView;
        _textView.textContainerInset = _textInset;
        
        if ([_message isKindOfClass:[NSAttributedString class]]) {
            _textView.attributedText = _message;
        }
        else {
            _textView.text = _message;
        }
        
        _textView.font = [UIFont systemFontOfSize:_fontSizeTextView weight:UIFontWeightRegular];
        _textView.textAlignment = _textAligment;
        
        CGSize fitSize = [_textView sizeThatFits:CGSizeMake(_textView.frame.size.width, MAXFLOAT)];
        CGFloat height = fitSize.height;
        if (fitSize.height < _minHeightTextView) {
            height = _minHeightTextView;
            _heightTextView.constant = height;
            _textView.contentOffset = CGPointMake(0, -(height - fitSize.height)/2);
        }
        else {
            _heightTextView.constant = fitSize.height;
        }
    }
    
    _svButton.hidden = YES;
    
    if (_btnTitles.count > 0) {
        _svButton.hidden = NO;
        _svButton.translatesAutoresizingMaskIntoConstraints = NO;
        _heightSvButton.constant = _heightBtn;
        
        if (_btnAlignment == AlertBtnAlignmentRight) {
            _svButton.distribution = UIStackViewDistributionFill;
            for (NSInteger i = _btnTitles.count - 1; i >= 0; i--) {
                
                UIButton *btn = [self getCustomBtnWithIndex:i];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                [_svButton insertArrangedSubview:btn atIndex:0];
                
                CGFloat minWidth = 80.0;
                if (i > 0) {
                    CGFloat space = 8;
                    CGSize sizeBtn = [btn.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, _heightBtn)];
                    CGFloat width = sizeBtn.width + 2*space;
                    
                    width = MAX(width, minWidth);
                    NSLayoutConstraint *constraint = [btn.widthAnchor constraintEqualToConstant:width];
                    constraint.priority = 999;
                    constraint.active = YES;
                }
                btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            }
        }
        else {
            _svButton.distribution = UIStackViewDistributionFillEqually;
            
            for (NSInteger i = 0; i < _btnTitles.count; i++) {
                UIButton *btn = [self getCustomBtnWithIndex:i];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                btn.titleLabel.adjustsFontSizeToFitWidth = YES;
                [_svButton addArrangedSubview:btn];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    CGSize newSize = [[change objectForKey:@"new"] CGSizeValue];
    _heightTextView.constant = newSize.height;
    
}

- (UIButton *)getCustomBtnWithIndex:(NSInteger)index {
    if (index > _btnTitles.count - 1) {
        return nil;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    id title = [_btnTitles objectAtIndex:index];
    
    UIColor *colorBG = DEFAULT_GREEN_COLOR;
    UIColor *colorTitle = DEFAULT_WHITE_COLOR;
    
    if (index < _btnBGColors.count) {
        colorBG = [_btnBGColors objectAtIndex:index];
    }
    
    if (index < _btnTitleColors.count) {
        colorTitle = [_btnTitleColors objectAtIndex:index];
    }
    
    btn.titleLabel.font = [UIFont systemFontOfSize:_fontSizeBtn weight:UIFontWeightMedium];
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [btn setTitleColor:colorTitle forState:UIControlStateNormal];
    btn.backgroundColor = colorBG;
    if ([title isKindOfClass:[NSAttributedString class]]) {
        [btn setAttributedTitle:title forState:UIControlStateNormal];
    }
    else {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    
    [btn addTarget:self action:@selector(onClickedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = index;
    return btn;
}

- (void)onClickedButtonAction:(UIButton *)sender {
    
    if (_acitonBlock) {
        self.acitonBlock(sender.tag);
    }
    [self dismiss];
}

- (void)show {
    self.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if ([window viewWithTag:Tag_View]) {
        [[window viewWithTag:Tag_View] removeFromSuperview];
    }
    self.tag = Tag_View;
    [window addSubview:self];
    
    [self configurationUI];
    _bgView.backgroundColor = [UIColor clearColor];
    _containerView.alpha = 0.0;
    _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.backgroundColor = RGBA(0, 0, 0, 0.2);
        self.containerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.containerView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    self.acitonBlock = nil;
    [UIView animateWithDuration:0.1
                     animations:^{
        self.transform = CGAffineTransformMakeScale(0, 0);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
