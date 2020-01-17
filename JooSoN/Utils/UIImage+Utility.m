//
//  UIImage+Utility.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

+ (UIImage *)imageNamed:(NSString *)name withTintColor:(UIColor *)tintColor {
    UIImage *img = [UIImage imageNamed:name];
    
    return [self tintedImageWithColor:tintColor image:img];
}
+ (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    // Build a context that's the same dimensions as the new size
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                kCGImageAlphaPremultipliedLast
                                                /*CGImageGetBitmapInfo(imageRef)*/);
    
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}
// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }
    else if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, newSize.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    
    if (self.imageOrientation == UIImageOrientationUpMirrored || self.imageOrientation == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, newSize.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    else if (self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, newSize.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    return transform;
}
- (UIImage *)resizedImageWithBounds:(CGSize)bounds {
    
    //uses the “aspect fit” approach to keep the aspect ratio intact
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    //creates a new image context and draws the image into that
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
