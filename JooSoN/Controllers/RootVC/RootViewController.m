//
//  RootViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "LeftSlideViewController.h"
#import "TabContainerController.h"
#import "HistoryViewController.h"
#import "DailingViewController.h"
#import "DestinationViewController.h"
#import "JooSoListViewController.h"
#import "AroundSearchViewController.h"
#import "UIImage+Utility.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface RootViewController () <TabContainerDelegate, TabContainerDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnLogo;
@property (weak, nonatomic) IBOutlet UIView *tabContainerView;
@property (nonatomic, strong) TabContainerController *tabController;
@property (nonatomic, strong) HistoryViewController *historyVC;
@property (nonatomic, strong) DailingViewController *inputCallVC;
@property (nonatomic, strong) DestinationViewController *destinationVC;
@property (nonatomic, strong) JooSoListViewController *joosoListVC;
@property (nonatomic, strong) AroundSearchViewController *aroundSearchVC;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabController = [[TabContainerController alloc] initWithNibName:@"TabContainerController" bundle:nil];
    _tabController.delegate = self;
    _tabController.dataSource = self;
    
    [_tabContainerView addSubview:_tabController.view];
    [_tabController initConstraintWithSuperView:_tabContainerView];
    [_tabController reloadData];
    _tabController.activeTabIndex = 0;
    
    BOOL haveUploadedToLocalDB = [[NSUserDefaults standardUserDefaults] boolForKey:HaveUploadedToLocalDB];
    if (haveUploadedToLocalDB == NO) {
        __weak typeof(self) weakSelf = self;
        [[DBManager instance] loadContacts:^(NSArray *arrData) {
            if (arrData.count > 0) {
                [weakSelf uplaodLocalDB:arrData];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HaveUploadedToLocalDB];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    
        [[NSUserDefaults standardUserDefaults] setObject:@"전체" forKey:EntityApointGroupName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *defalutGroupNames = [NSArray arrayWithObjects:@"가족", @"직장동료", @"학교", nil];
        for (NSString *name in defalutGroupNames) {
            [[DBManager instance] insertGroupName:name count:0 success:nil fail:nil];
        }
    }
}

- (void)uplaodLocalDB:(NSArray *)arrData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DBManager instance] uploadAllContactsToLocalDB:arrData success:^{
            NSLog(@"success save all jooso in localDB");
        } fail:^(NSError *error) {
            NSLog(@"error : %@", error.localizedDescription);
        }];
    });
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotiChangeMapId object:nil];
    if (_tabController.activeTabIndex == 0) {
        [_historyVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_inputCallVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 2) {
        [_destinationVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 3) {
        [_joosoListVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 4) {
        [_aroundSearchVC beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_tabController.activeTabIndex == 0) {
        [_historyVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_inputCallVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 2) {
        [_destinationVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 3) {
        [_joosoListVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 4) {
        [_aroundSearchVC endAppearanceTransition];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_tabController.activeTabIndex == 0) {
        [_historyVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_inputCallVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 2) {
        [_destinationVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 3) {
        [_joosoListVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 4) {
        [_aroundSearchVC beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_tabController.activeTabIndex == 0) {
        [_historyVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_inputCallVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 2) {
        [_destinationVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 3) {
        [_joosoListVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 4) {
        [_aroundSearchVC endAppearanceTransition];
    }
}

- (IBAction)onClickedButtonAction:(id)sender {
    
    if (sender == _btnLogo) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController showLeftViewAnimated:YES completionHandler:^{
            [((LeftSlideViewController*)mainViewController.leftViewController).tblView reloadData];
        }];
    }
}

#pragma mark - TabContainerDelegate, TabContainerDataSource
- (UIViewController *)tabContainer:(TabContainerController *)tabContainer contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        self.historyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
        return _historyVC;
    }
    else if (index == 1) {
        self.inputCallVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DailingViewController"];
        return _inputCallVC;
    }
    else if (index == 2) {
        self.destinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DestinationViewController"];
        return _destinationVC;
    }
    else if (index == 3) {
        self.joosoListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JooSoListViewController"];
        return _joosoListVC;
    }
    else {
        self.aroundSearchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AroundSearchViewController"];
        return _aroundSearchVC;
    }
}

- (UIView *)tabContainer:(TabContainerController *)tabContainer viewForTabAtIndex:(NSUInteger)index {
    
    NSString *titleStr = nil;
    if (index == 0) {
        titleStr = @"최근목록";
    }
    else if (index == 1) {
        titleStr = @"다이얼";
    }
    else if (index == 2) {
        titleStr = @"목적지";
    }
    else if (index == 3) {
        titleStr = @"주소록";
    }
    else {
        titleStr = @"주변검색";
    }

    UIButton *btn = [self makeTabButton:titleStr];
    return btn;
}

- (UIButton *)makeTabButton:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:RGB(137, 137, 137) forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageFromColor:RGB(225, 225, 225)] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageFromColor:RGB(33, 170, 164)] forState:UIControlStateSelected];
    
    return btn;
}

- (NSUInteger)numberOfTabsForTabContainer:(TabContainerController *)tabContainer {
    return 5;
}

- (CGFloat)heightForTabInTabContainer:(TabContainerController *)tabContainer heightComponent:(TabComponentHeight)component {
    if (component == TabButtonHeight) {
        return 40;
    }
    else {
        return 0;
    }
}

- (UIColor *)tabContainer:(TabContainerController *)tabContainer colorForComponent:(TabComponentColor)component {
    if (component == TCIndicatorColor) {
        return nil;
    }
    else if (component == TCIndicatorDefaultColor) {
        return RGB(216, 216, 216);
    }
    else if (component == TCIndicatorBackGroundColor) {
        return [UIColor whiteColor];
    }
    
    return nil;
}

- (void)tabContainer:(TabContainerController *)tabContainer didChangeTabToIndex:(NSUInteger)index {
    NSLog(@"hck : %ld", index);
    
//    if (index == 0) {
//        [_historyViewController reloadData];
//    }
//    else if (index == 1) {
//        [_drHistoryViewController reloadData];
//    }
}

#pragma mark - notificationHandler:
- (void)notificationHandler:(NSNotification *)notification {
    if ([notification.name isEqualToString:NotiChangeMapId]) {
        NSInteger activateIndex = _tabController.activeTabIndex;
        [self.tabController reloadData];
        self.tabController.activeTabIndex = activateIndex;
    }
}
@end
