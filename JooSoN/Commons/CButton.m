//
//  CButton.m
//  Hanpass
//
//  Created by 김학철 on 14/11/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import "CButton.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
@interface CButton ()
@property (nonatomic, strong) CAShapeLayer *subLayer;
@property (nonatomic, strong) CALayer *borderLayer;
@property (nonatomic, strong) UIColor *bgColor;
@end
@implementation CButton
- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.numberOfLines = 0;
    [self decorationComponent];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self decorationComponent];
}
- (void)decorationComponent {
    [self decorationTitle];
    [self decorationShape];
}

- (void)decorationTitle {
    if (_localizeText.length > 0) {
        [self setTitle:NSLocalizedString(_localizeText, @"") forState:UIControlStateNormal];
        [self setTitle:NSLocalizedString(_localizeText, @"") forState:UIControlStateHighlighted];
        [self setTitle:NSLocalizedString(_localizeText, @"") forState:UIControlStateSelected];
    }
    else {
        [self setTitle:@"" forState:UIControlStateNormal];
        [self setTitle:@"" forState:UIControlStateHighlighted];
        [self setTitle:@"" forState:UIControlStateSelected];
    }
    
    for (NSLayoutConstraint *heightConstraint in self.constraints) {
        if ([heightConstraint.identifier isEqualToString:@"height"]) {
            if (self.originHeight == 0) {
                self.originHeight = heightConstraint.constant;
            }
            
            CGFloat height = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT)].height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
            height = MAX(height, _originHeight);
            heightConstraint.constant = height;
        }
    }
    [self layoutIfNeeded];
    [self decorationShape];
}

- (void)decorationShape {
    if (_borderBottom) {
        if (_borderLayer) {
            [_borderLayer removeFromSuperlayer];
        }
        self.borderLayer = [CALayer layer];
        _borderLayer.backgroundColor = _borderColor.CGColor;
        _borderLayer.frame = CGRectMake(0, self.frame.size.height - _borderWidth, self.frame.size.width, _borderWidth);
        
        [self.layer addSublayer:_borderLayer];
        self.layer.masksToBounds = YES;
    }
    else if (_borderAll) {
        self.layer.borderWidth = _borderWidth;
        self.layer.borderColor = _borderColor.CGColor;
    }
    
    if (_isHalfCornerRaduis) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height/2;
    }
    else if (_cornerRadius > 0) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = _cornerRadius;
    }
    
    if (_shadowColor != nil) {
        self.layer.masksToBounds = NO;
        
        if (_subLayer) {
            [_subLayer removeFromSuperlayer];
        }
        
        if ([self.backgroundColor isEqual:[UIColor clearColor]] == NO) {
            self.bgColor = self.backgroundColor;
        }
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.backgroundColor = [UIColor clearColor];
        
        self.subLayer = [[CAShapeLayer alloc] init];
        _subLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius] CGPath];
        _subLayer.fillColor = _bgColor.CGColor;
        _subLayer.shadowOffset = _shadowOffset;
        _subLayer.shadowColor = _shadowColor.CGColor;
        _subLayer.shadowRadius = _shadowRadius;
        _subLayer.shadowOpacity = _shadowOpacity;
        
        [self.layer insertSublayer:_subLayer atIndex:0];
    }
}
- (void)setLocalizeText:(NSString *)localizeText {
    _localizeText = localizeText;
    [self setNeedsDisplay];
}
- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}
- (void)setIsHalfCornerRaduis:(BOOL)isHalfCornerRaduis {
    _isHalfCornerRaduis = isHalfCornerRaduis;
    [self setNeedsDisplay];
}
//shadow
- (void)setBorderAll:(BOOL)borderAll {
    _borderAll = borderAll;
    [self setNeedsDisplay];
}
- (void)setBorderBottom:(BOOL)borderBottom {
    _borderBottom = borderBottom;
    [self setNeedsDisplay];
}
- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}
- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self setNeedsDisplay];
}
- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    [self setNeedsDisplay];
}
- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    _shadowOpacity = shadowOpacity;
    [self setNeedsDisplay];
}

@end
