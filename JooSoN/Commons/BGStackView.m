//
//  BGStackView.m
//  Hanpass
//
//  Created by 김학철 on 27/09/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import "BGStackView.h"
@interface BGStackView ()
@property (nonatomic, strong) CAShapeLayer *subLayer;
@end
@implementation BGStackView
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
       
    }
    return self;
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.subLayer = [[CAShapeLayer alloc] init];
    [self.layer insertSublayer:_subLayer atIndex:0];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _subLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    if (_bgColor != nil) {
        _subLayer.fillColor = _bgColor.CGColor;
    }
}
- (void)addBgColor {
    if (_bgColor != nil) {
        UIView *subView = [[UIView alloc] init];
        subView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:subView atIndex:0];
    }
}
@end
