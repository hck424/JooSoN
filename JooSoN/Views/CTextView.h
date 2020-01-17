//
//  CTextView.h
//  Hanpass
//
//  Created by 김학철 on 31/10/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface CTextView : UITextView
@property (nonatomic, assign) IBInspectable CGFloat insetTop;
@property (nonatomic, assign) IBInspectable CGFloat insetBottom;
@property (nonatomic, assign) IBInspectable CGFloat insetLeft;
@property (nonatomic, assign) IBInspectable CGFloat insetRight;

@end
