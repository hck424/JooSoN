//
//  BGStackView.h
//  Hanpass
//
//  Created by 김학철 on 27/09/2019.
//  Copyright © 2019 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>


IB_DESIGNABLE
@interface BGStackView : UIStackView
@property (nonatomic, strong) IBInspectable UIColor *bgColor;
@property (nonatomic, strong) id data;
@end


