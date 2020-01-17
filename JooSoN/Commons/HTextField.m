//
//  HTextField.m
//  Hanpass
//
//  Created by 김학철 on 29/09/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import "HTextField.h"
#define DEFAULT_BORDER_COLOR RGB(216, 216, 216)
#define DEFAULT_BORDER_COLOR_SELECTED  RGB(23, 133, 239)
#define DEFAULT_BORDER_COLOR_WORING  RGB(255, 0, 0)
#define DEFAULT_PLACE_HOLDER_COLOR   RGB(153, 153, 153)

@interface HTextField ()
@property (nonatomic, strong) CALayer *subLayer;
@end
@implementation HTextField

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.borderStyle = UITextBorderStyleNone;
    
    if (_borderWidth == 0) {
        _borderWidth = 1.0;
    }
    if (_borderColor == nil) {
        _borderColor = DEFAULT_BORDER_COLOR;
    }
    
    if (_borderBottom) {
        if (_subLayer) {
            [_subLayer removeFromSuperlayer];
        }
        self.subLayer = [CALayer layer];
        _subLayer.backgroundColor = _borderColor.CGColor;
        _subLayer.frame = CGRectMake(0, self.frame.size.height - _borderWidth, self.frame.size.width, _borderWidth);
        
       [self.layer addSublayer:_subLayer];
       self.layer.masksToBounds = YES;
    }
    else if (_borderAll) {
        self.layer.borderWidth = _borderWidth;
        self.layer.borderColor = _borderColor.CGColor;
    }
    
    if (_localizablePlaceHolder.length > 0) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(_localizablePlaceHolder, @"")];
        
        if (_colorPlaceHolder == nil) {
            _colorPlaceHolder = DEFAULT_PLACE_HOLDER_COLOR;
        }
        
        [attr addAttribute:NSForegroundColorAttributeName value:_colorPlaceHolder range:NSMakeRange(0, attr.string.length)];
        
        self.attributedPlaceholder = attr;
    }
   
    if (_cornerRaduis > 0) {
        self.layer.cornerRadius = _cornerRaduis;
        self.layer.masksToBounds = YES;
    }
}

// ibdesinable setter
- (void)setBorderBottom:(BOOL)borderBottom {
    _borderBottom = borderBottom;
    [self setNeedsDisplay];
}
- (void)setBorderAll:(BOOL)borderAll {
    _borderAll = borderAll;
    [self setNeedsDisplay];
}
- (void)setLocalizablePlaceHolder:(NSString *)localizablePlaceHolder {
    _localizablePlaceHolder = localizablePlaceHolder;
    [self setNeedsDisplay];
}
- (void)setColorPlaceHolder:(UIColor *)colorPlaceHolder {
    _colorPlaceHolder = colorPlaceHolder;
    [self setNeedsDisplay];
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}
- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}
- (void)setCornerRaduis:(CGFloat)cornerRaduis {
    _cornerRaduis = cornerRaduis;
    [self setNeedsLayout];
}
//local setter
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _borderColor = _isSelected? DEFAULT_BORDER_COLOR_SELECTED : DEFAULT_BORDER_COLOR;
    [self setNeedsDisplay];
}
- (void)setIsWaring:(BOOL)isWaring {
    _isWaring = isWaring;
    _borderColor = _isWaring? DEFAULT_BORDER_COLOR_WORING : DEFAULT_BORDER_COLOR;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, _insetX, _insetY);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, _insetX, _insetY);
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (action == @selector(paste:)) {
//        return YES;
//    }
    return [super canPerformAction:action withSender:sender];
}

@end
