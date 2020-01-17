//
//  UIView+Utility.h
//  ParkingGo
//
//  Created by 김학철 on 03/11/2019.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utility)
- (void)startAnimationWithRaduis:(CGFloat)raduis;
- (void)stopAnimation;
- (void)addShadow:(CGSize)offset color:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity;
- (void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;
@end
