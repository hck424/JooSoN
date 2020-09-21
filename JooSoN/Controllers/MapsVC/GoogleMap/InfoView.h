//
//  InfoView.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/18.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
NS_ASSUME_NONNULL_BEGIN

@interface InfoView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;

@end

NS_ASSUME_NONNULL_END
