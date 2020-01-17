//
//  VerticalButton.m
//  JooSoN
//
//  Created by 학철 on 2018. 3. 11..
//  Copyright © 2018년 학철. All rights reserved.
//

#import "VerticalButton.h"
IB_DESIGNABLE
@implementation VerticalButton


- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake((self.frame.size.width - _imgWidth)/2,
                                      self.imageEdgeInsets.top,
                                      _imgWidth,
                                      _imgHeight);
    self.titleLabel.frame = CGRectMake(self.titleEdgeInsets.left,
                                       self.imageEdgeInsets.top + _imgHeight + _space,
                                       self.frame.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right,
                                       self.frame.size.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - _space - _imgHeight);

    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.imageView.frame = CGRectMake((self.frame.size.width - _imgWidth)/2,
//                                      self.imageEdgeInsets.top,
//                                      _imgWidth,
//                                      _imgHeight);
//    self.titleLabel.frame = CGRectMake(self.titleEdgeInsets.left,
//                                       self.imageEdgeInsets.top + _imgHeight + _space,
//                                       self.frame.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right,
//                                       self.frame.size.height - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - _space - _imgHeight);
//
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
//}
- (void)setImgWidth:(CGFloat)imgWidth {
    _imgWidth = imgWidth;
    [self setNeedsDisplay];
}
- (void)setImgHeight:(CGFloat)imgHeight {
    _imgHeight = imgHeight;
    [self setNeedsDisplay];
}
- (void)setSpace:(CGFloat)space {
    _space = space;
    [self setNeedsDisplay];
}
@end
