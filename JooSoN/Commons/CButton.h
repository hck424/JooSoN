//
//  CButton.h
//  Hanpass
//
//  Created by 김학철 on 14/11/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface CButton : UIButton
@property (nonatomic, strong) IBInspectable NSString *localizeText;
@property (nonatomic, assign) IBInspectable BOOL borderAll;
@property (nonatomic, assign) IBInspectable BOOL borderBottom;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable BOOL isHalfCornerRaduis;
@property (nonatomic, strong) IBInspectable UIColor *shadowColor;
@property (nonatomic, assign) IBInspectable CGSize shadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat shadowRadius;
@property (nonatomic, assign) IBInspectable CGFloat shadowOpacity;

@property (nonatomic, assign) NSInteger originHeight;
@property (nonatomic, strong) id data;

- (void)decorationTitle;
- (void)decorationShape;
@end

