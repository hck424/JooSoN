//
//  TabContainerController.h
//  TabContainer
//
//  Created by 김학철 on 03/10/2019.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    TCIndicatorColor,
    TCIndicatorDefaultColor,
    TCIndicatorBackGroundColor,
} TabComponentColor;

typedef enum {
    TabButtonHeight,
    TabIndicatorHeight,
    TabIndicatorSelectedHeight,
} TabComponentHeight;


@protocol TabContainerDataSource;
@protocol TabContainerDelegate;

@interface TabContainerController : UIViewController
@property (nonatomic, assign) NSInteger activeTabIndex;

@property (nonatomic, weak) id <TabContainerDelegate>delegate;
@property (nonatomic, weak) id <TabContainerDataSource>dataSource;
- (void)reloadData;
- (void)initConstraintWithSuperView:(UIView *)superView;
- (void)setButtonTitle:(NSString *)title btnIndex:(NSInteger)btnIndex;

@end


@protocol TabContainerDataSource <NSObject>

@required
- (NSUInteger)numberOfTabsForTabContainer:(TabContainerController *)tabContainer;
- (UIButton *)tabContainer:(TabContainerController *)tabContainer viewForTabAtIndex:(NSUInteger)index;
- (UIViewController *)tabContainer:(TabContainerController *)tabContainer contentViewControllerForTabAtIndex:(NSUInteger)index;
@optional
- (CGFloat)heightForTabInTabContainer:(TabContainerController *)tabContainer heightComponent:(TabComponentHeight)component;
- (UIColor *)tabContainer:(TabContainerController *)tabContainer colorForComponent:(TabComponentColor)component;

@end

@protocol TabContainerDelegate <NSObject>

@optional

- (void)tabContainer:(TabContainerController *)tabContainer didChangeTabToIndex:(NSUInteger)index;


@end

