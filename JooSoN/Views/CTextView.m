//
//  CTextView.m
//  Hanpass
//
//  Created by 김학철 on 31/10/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import "CTextView.h"

@implementation CTextView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layoutManager.allowsNonContiguousLayout = NO;
    self.textContainer.lineFragmentPadding = 0.0f;
    self.textContainerInset = UIEdgeInsetsMake(_insetTop, _insetLeft, _insetBottom, _insetRight);
}

- (void)setInsetTop:(CGFloat)insetTop {
    _insetTop = insetTop;
}
- (void)setInsetBottom:(CGFloat)insetBottom {
    _insetBottom = insetBottom;
}
- (void)setInsetLeft:(CGFloat)insetLeft {
    _insetLeft = insetLeft;
}
- (void)setInsetRight:(CGFloat)insetRight {
    _insetRight = insetRight;
}
@end
