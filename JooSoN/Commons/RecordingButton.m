//
//  RecordingButton.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/23.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "RecordingButton.h"
@interface RecordingButton ()
@property (nonatomic, strong) UIColor *pulseColor;
@property (nonatomic, assign) CGFloat pulseDuration;
@property (nonatomic, assign) CGFloat pulseRadius;

@property (nonatomic, strong) CAShapeLayer *mainLayer;
@property (nonatomic, assign) BOOL isAnimation;

@end
@implementation RecordingButton
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pulseColor = RGB(40, 210, 180);
    self.pulseDuration = 1.0f;
    self.pulseRadius = 1.5;
    [self createMainLayer];
    [self.layer addSublayer:_mainLayer];
}
- (void)createMainLayer {
    self.mainLayer = [[CAShapeLayer alloc] init];
    _mainLayer.backgroundColor = _pulseColor.CGColor;
    _mainLayer.bounds = self.bounds;
    _mainLayer.cornerRadius = self.bounds.size.width/2;
    _mainLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _mainLayer.zPosition = -1;
}
- (CAShapeLayer *)createAnimationLayer {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.backgroundColor = _pulseColor.CGColor;
    layer.bounds = self.bounds;
    layer.cornerRadius = self.bounds.size.width/2;
    layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    layer.zPosition = -2;
    layer.opacity = 0;
    return layer;
}
- (CABasicAnimation *)createScaleAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:(_pulseRadius + 1)];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return  scaleAnimation;
}

- (CAKeyframeAnimation *) createOpacityAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = @[[NSNumber numberWithFloat:0.8], [NSNumber numberWithFloat:0.4], [NSNumber numberWithFloat:0.0]];
    animation.keyTimes = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0]];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return  animation;
}
- (void)animation:(BOOL)animation {
    _isAnimation = animation;
    [self handleAnimations];
    
    if (_isAnimation) {
        [self setImage:[UIImage imageNamed:@"mic-lg-active"] forState:UIControlStateNormal];
    }
    else {
        [self setImage:[UIImage imageNamed:@"mic-lg-inactive"] forState:UIControlStateNormal];
    }
}

- (void)handleAnimations {
    if (!_isAnimation) {
        return;
    }
    
    CALayer *layer = [self createAnimationLayer];
    [self.layer insertSublayer:layer below:_mainLayer];
    
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.animations = @[[self createScaleAnimation], [self createOpacityAnimation]];
    animationGroup.duration = _pulseDuration;
    [layer addAnimation:animationGroup forKey:@"pulse"];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf handleAnimations];
    });
}

@end
