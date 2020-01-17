//
//  TabContainerController.m
//  TabContainer
//
//  Created by 김학철 on 03/10/2019.
//  Copyright © 2019 김학철. All rights reserved.
//


#import "TabContainerController.h"

@interface TabContainerController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIStackView *svMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTab;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) NSInteger tabCount;
@property (nonatomic, strong) UIViewController *selectedViewController;

@end

@implementation TabContainerController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewControllers = [NSMutableArray array];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}
- (void)reloadData {
    
    if ([self.dataSource respondsToSelector:@selector(numberOfTabsForTabContainer:)]) {
         self.tabCount = [_dataSource numberOfTabsForTabContainer:self];
    }
    
    [_viewControllers removeAllObjects];
    
    for (UIView *subView in _svMenu.subviews) {
        [subView removeFromSuperview];
    }
    
    if ([_dataSource respondsToSelector:@selector(heightForTabInTabContainer:heightComponent:)]) {
        _heightTab.constant = [_dataSource heightForTabInTabContainer:self heightComponent:TabButtonHeight];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger i = 0; i < _tabCount; i++) {
        if ([self.dataSource respondsToSelector:@selector(tabContainer:viewForTabAtIndex:)]) {
            UIButton *btnTap = [_dataSource tabContainer:self viewForTabAtIndex:i];
            [btnTap addTarget:self action:@selector(onClickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.clipsToBounds = NO;
            [_svMenu addArrangedSubview:btnTap];
        }
    }
    
    for (NSInteger i = 0; i < _tabCount; i++) {
        if ([self.dataSource respondsToSelector:@selector(tabContainer:contentViewControllerForTabAtIndex:)]) {
            UIViewController *viewCon = [_dataSource tabContainer:self contentViewControllerForTabAtIndex:i];
            [_viewControllers addObject:viewCon];
        }
    }
}
- (void)setActiveTabIndex:(NSInteger)activeTabIndex {
    _activeTabIndex = activeTabIndex;
    if (_activeTabIndex < 0
        && _activeTabIndex > [_svMenu subviews].count) {
        _activeTabIndex = 0;
    }
    
    @try {
        [[_svMenu.arrangedSubviews objectAtIndex:_activeTabIndex] sendActionsForControlEvents:UIControlEventTouchUpInside];
    } @catch (NSException *exception) {
        NSLog(@"exception : %@", [exception callStackSymbols]);
    }
}
- (void)setButtonTitle:(NSString *)title btnIndex:(NSInteger)btnIndex {
    UIButton *btn = [_svMenu.subviews objectAtIndex:btnIndex];
    [btn setTitle:title forState:UIControlStateNormal];
}
- (void)onClickButtonAction:(UIButton *)sender {
    NSArray *menuButtons = [_svMenu arrangedSubviews];
    
    for (NSInteger i=0; i < [menuButtons count]; i++) {
        UIButton *btn = [menuButtons objectAtIndex:i];
        
        for (UIView *subView in [btn subviews]) {
            if ([subView.accessibilityValue isEqualToString:@"bttom_border"]) {
                [subView removeFromSuperview];
            }
        }
        
        if (btn == sender) {
            btn.selected = YES;
            if ([_dataSource respondsToSelector:@selector(tabContainer:colorForComponent:)]) {
                
                UIColor *indeCatorColor = [_dataSource tabContainer:self colorForComponent:TCIndicatorColor];
                
                [self addUnderLine:btn indicatorColor:indeCatorColor];
                
            }
            
            [self displayContentController:[_viewControllers objectAtIndex:i]];
            if (_activeTabIndex != i) {
                if ([self.delegate respondsToSelector:@selector(tabContainer:didChangeTabToIndex:)]) {
                    [_delegate tabContainer:self didChangeTabToIndex:i];
                }
                _activeTabIndex = i;
            }
        } else {
            btn.selected = NO;
            if ([_dataSource respondsToSelector:@selector(tabContainer:colorForComponent:)]) {
                
                UIColor *indeCatorColor = [_dataSource tabContainer:self colorForComponent:TCIndicatorDefaultColor];
                
                [self addUnderLine:btn indicatorColor:indeCatorColor];
            }
        }
    }
}

- (void)addUnderLine:(UIButton *)btn indicatorColor:(UIColor *)color {
    
    CGFloat heightBoder = 0.0;
    CGFloat selHeightBoder = 0.0;
    if ([self.dataSource heightForTabInTabContainer:self heightComponent:TabIndicatorHeight]) {
        heightBoder = [_dataSource heightForTabInTabContainer:self heightComponent:TabIndicatorHeight];
    }
    
    if ([self.dataSource heightForTabInTabContainer:self heightComponent:TabIndicatorHeight]) {
        selHeightBoder = [_dataSource heightForTabInTabContainer:self heightComponent:TabIndicatorSelectedHeight];
    }
    
    if (btn.selected) {
        heightBoder = selHeightBoder;
    }
    
    UIView *indecatorView = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height - heightBoder, btn.frame.size.width, heightBoder)];
    [btn addSubview:indecatorView];
    indecatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    indecatorView.backgroundColor = color;
    indecatorView.accessibilityValue = @"bttom_border";
}

- (void)displayContentController:(UIViewController *)viewController {
    if (_selectedViewController != nil
        && _selectedViewController != viewController) {
        [self myRemoveChildViewController:_selectedViewController];
    }
    
    self.selectedViewController = viewController;
    [self myAddChildViewController:viewController];
    
}
- (void)initConstraintWithSuperView:(UIView *)superView {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.topAnchor constraintEqualToAnchor:superView.topAnchor constant:0].active = YES;
    [self.view.leadingAnchor constraintEqualToAnchor:superView.leadingAnchor constant:0].active = YES;
    [self.view.trailingAnchor constraintEqualToAnchor:superView.trailingAnchor constant:0].active = YES;
    [self.view.bottomAnchor constraintEqualToAnchor:superView.bottomAnchor constant:0].active = YES;
    
}
- (void)addConstraint:(UIView *)subView {
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [subView.topAnchor constraintEqualToAnchor:_svMenu.bottomAnchor constant:0].active = YES;
    [subView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [subView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [subView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
}
- (void)myAddChildViewController:(UIViewController *)childController {
    [self addChildViewController:childController]; //add the child on childViewControllers array
    [childController willMoveToParentViewController:self]; //viewWillAppear on childViewController
    [self.view addSubview:childController.view]; //add childView whenever you want
    [self addConstraint:childController.view];
    [childController didMoveToParentViewController:self];
}

- (void)myRemoveChildViewController:(UIViewController *)viewController{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

@end
