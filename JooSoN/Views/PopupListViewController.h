//
//  PopupListViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGStackView.h"
#import "UIView+Utility.h"

typedef enum {
  PopupListTypeDefault,
  PopupListTypeEding
} PopupListType;


IB_DESIGNABLE
@protocol PopupListViewControllerDelegate <NSObject>
- (void)popupListViewController:(UIViewController *)vc type:(PopupListType)type dataIndex:(NSInteger)dataIndex selecteData:(id)data btnIndex:(NSInteger)btnIndex;
@end
@interface PopupListViewController : UIViewController
@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) NSArray *arrBtnTitle;
@property (nonatomic, strong) NSArray *arrBtnTitleColor;
@property (nonatomic, strong) NSString *popupTitle;
@property (nonatomic, strong) NSString *endingFieldTitle;
@property (nonatomic, assign) PopupListType popupType;
@property (nonatomic, weak) id <PopupListViewControllerDelegate>delegate;


@end
