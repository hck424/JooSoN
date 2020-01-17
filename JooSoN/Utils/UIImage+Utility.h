//
//  UIImage+Utility.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIImage (Utility)
+ (UIImage *)imageNamed:(NSString *)name withTintColor:(UIColor *)tintColor;
+ (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image;
+ (UIImage *)imageFromColor:(UIColor *)color;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithBounds:(CGSize)bounds;
@end
