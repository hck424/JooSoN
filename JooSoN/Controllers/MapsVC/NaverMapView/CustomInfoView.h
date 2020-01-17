//
//  CustomInfoView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/10.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomInfoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *ivBg;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTitle;

@end

NS_ASSUME_NONNULL_END
