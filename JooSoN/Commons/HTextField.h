//
//  HTextField.h
//  Hanpass
//
//  Created by 김학철 on 29/09/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTextField : UITextField
@property (nonatomic, assign) IBInspectable NSUInteger insetX;
@property (nonatomic, assign) IBInspectable NSUInteger insetY;
@property (nonatomic, strong) IBInspectable NSString *localizablePlaceHolder;
@property (nonatomic, strong) IBInspectable UIColor *colorPlaceHolder;

@property (nonatomic, assign) IBInspectable BOOL borderBottom;
@property (nonatomic, assign) IBInspectable BOOL borderAll;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRaduis;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isWaring;

@end

