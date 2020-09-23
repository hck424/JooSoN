//
//  PopupListViewController.h
//  Hanpass
//
//  Created by 김학철 on 2020/07/14.
//  Copyright © 2020 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
NS_ASSUME_NONNULL_BEGIN
@interface BottomPopupViewController : UIViewController
@property (nonatomic, assign) BOOL showTopSeperator;
@property (nonatomic, assign) BOOL showSearchBar;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL showTableViewSeperator;
@property (nonatomic, assign) BOOL enableBgTouchClose;
@property (nonatomic, assign) BOOL showAnimation;
@property (nonatomic, assign) BOOL dismissAnimation;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, strong) UIFont *fontText;
@property (nonatomic, strong) UIFont *fontSubText;
@property (nonatomic, strong) UIColor *colorText;
@property (nonatomic, strong) UIColor *colorSubText;
@property (nonatomic, assign) CGSize sizeThumnail;

- (instancetype)initWidthType:(BottomPopupType)type title:(NSString *)title data:(NSArray *)data keys:(NSArray *)keys completion:(void (^)(UIViewController *vcs, id selData, MapCellAction action))completion;


@end
NS_ASSUME_NONNULL_END
