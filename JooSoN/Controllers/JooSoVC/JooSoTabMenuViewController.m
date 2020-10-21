//
//  JooSoTabMenuViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "JooSoTabMenuViewController.h"
#import "TabContainerController.h"
#import "FavoriteListViewController.h"
#import "TotalJooSoListViewController.h"
#import "GroupListViewController.h"
#import "UIImage+Utility.h"
#import "UIView+Utility.h"
#import "AddJooSoViewController.h"
#import "DelJooSoViewController.h"
#import "GroupManageViewController.h"
#import "DBManager.h"
#import "UIView+Toast.h"
#import "PopupListViewController.h"

@interface JooSoTabMenuViewController () <TabContainerDelegate, TabContainerDataSource, PopupListViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (weak, nonatomic) IBOutlet UIButton *btnJoosoDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnJoosoAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupApoint;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupManager;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (nonatomic, strong) TabContainerController *tabController;
@property (nonatomic, strong) FavoriteListViewController *favoriteListVC;
@property (nonatomic, strong) TotalJooSoListViewController *totalListVC;
@property (nonatomic, strong) GroupListViewController *groupListVC;


@property (nonatomic, strong) NSString *searchStr;
@end

@implementation JooSoTabMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabController = [[TabContainerController alloc] initWithNibName:@"TabContainerController" bundle:nil];
    
    _tabController.delegate = self;
    _tabController.dataSource = self;
    
    [_tabView addSubview:_tabController.view];
    [_tabController initConstraintWithSuperView:_tabView];
    [_tabController reloadData];
    _tabController.activeTabIndex = 1;
    _tfSearch.inputAccessoryView = _accessoryView;
    
    [self.view addSubview:_floatView];
    _floatView.translatesAutoresizingMaskIntoConstraints = NO;
    [_floatView.topAnchor constraintEqualToAnchor:_btnAdd.topAnchor constant:50].active = YES;
    [_floatView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10].active = YES;
    [_floatView.widthAnchor constraintEqualToConstant:130].active = YES;
    [_floatView.heightAnchor constraintEqualToConstant:170].active = YES;
    
    
    _floatView.layer.cornerRadius = 16;
    _floatView.layer.borderColor = RGB(36, 183, 179).CGColor;
    _floatView.layer.borderWidth = 1.0f;
    [_floatView addShadow:CGSizeMake(5, 5) color:RGBA(0, 0, 0, 0.5) radius:3 opacity:0.5];

    _floatView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_tabController.activeTabIndex == 0) {
        [_favoriteListVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_totalListVC beginAppearanceTransition:YES animated:animated];
    }
    else {
        [_groupListVC beginAppearanceTransition:YES animated:animated];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotiNameHitTestView object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillHideNotification object:nil];
//    _tfSearch.text = @"";
//    self.searchStr = @"";
//    [self.view endEditing:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_tabController.activeTabIndex == 0) {
        [_favoriteListVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_totalListVC endAppearanceTransition];
    }
    else {
        [_groupListVC endAppearanceTransition];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_tabController.activeTabIndex == 0) {
        [_favoriteListVC beginAppearanceTransition:YES animated:animated];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_totalListVC beginAppearanceTransition:YES animated:animated];
    }
    else {
        [_groupListVC beginAppearanceTransition:YES animated:animated];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiNameHitTestView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_tabController.activeTabIndex == 0) {
        [_favoriteListVC endAppearanceTransition];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_totalListVC endAppearanceTransition];
    }
    else {
        [_groupListVC endAppearanceTransition];
    }
}

- (IBAction)onClickedButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [_tfSearch resignFirstResponder];
        
    }
    else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        if (btn == _btnAdd) {
            _floatView.hidden = NO;
        }
        else if (btn == _btnJoosoAdd) {
            NSLog(@"AA");
            AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
            vc.viewType = ViewTypeAdd;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (btn == _btnJoosoDelete) {
            DelJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DelJooSoViewController"];
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (btn == _btnGroupApoint) {
            
            __weak typeof (self) weakSelf = self;
            [[DBManager instance] getAllGroupName:^(NSArray *arrData) {
                if (arrData.count > 0) {
                    [weakSelf showPopup:arrData];
                }
                else {
                    [self.view makeToast:@"그룹이 리스트가 없습니다./n그룹 관리에서 그룹을 추가해 주세요." duration:1.0 position:CSToastPositionTop];
                }
            } fail:^(NSError *error) {
                NSLog(@"error: group all list > %@", error);
            }];
        }
        else if (btn == _btnGroupManager) {
            GroupManageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupManageViewController"];
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (btn == _btnMic) {
            [SpeechAlertView showWithTitle:@"JooSoN" completion:^(NSString * _Nonnull result) {
                if (result.length > 0) {
                    self.tfSearch.text = result;
                    [self setSearchTxt:result];
                }
            }];
        }
    }
}

- (void)showPopup:(NSArray *)arrData {
    NSMutableArray *arr = [NSMutableArray array];
    
    [arr addObject:@"전체"];
    for (GroupName *group in arrData) {
        [arr addObject:group.name];
    }

    PopupListViewController *vc = [[PopupListViewController alloc] initWithNibName:@"PopupListViewController" bundle:nil];
    vc.arrData = arr;
    vc.popupTitle = @"그룹을 지정해 주세요";
    vc.arrBtnTitle = @[@"취소"];
    vc.arrBtnTitleColor = @[[UIColor redColor]];
    vc.popupType = PopupListTypeDefault;
    vc.delegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[[AppDelegate instance].rootNavigationController topViewController] presentViewController:vc animated:NO completion:nil];

    
}
- (void)notificationHandler:(NSNotification *)notification {
    if ([notification.name isEqualToString:NotiNameHitTestView]) {
        if (_floatView != nil && _floatView.hidden == NO) {
            _floatView.hidden = YES;
        }
    }
}
- (void)setSearchTxt:(NSString *)str {
    if (_tabController.activeTabIndex == 0) {
        [_favoriteListVC setSearchText:str];
    }
    else if (_tabController.activeTabIndex == 1) {
        [_totalListVC setSearchText:str];
    }
    else {
        [_groupListVC setSearchText:str];
    }
}
#pragma makr - UITextField EditingValueChanged
- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    [self setSearchTxt:sender.text];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.view makeToast:@"검색어를 입력해주세요." duration:1.0 position:CSToastPositionTop];
    }
    else {
        [self setSearchTxt:textField.text];
    }
    return YES;
}


#pragma mark - TabContainerDelegate, TabContainerDataSource
- (UIViewController *)tabContainer:(TabContainerController *)tabContainer contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        self.favoriteListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoriteListViewController"];
        
        return _favoriteListVC;
    }
    else if (index == 1) {
        
        self.totalListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TotalJooSoListViewController"];
        return _totalListVC;
    }
    else {
        self.groupListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupListViewController"];
    
        return _groupListVC;
    }
}

- (UIView *)tabContainer:(TabContainerController *)tabContainer viewForTabAtIndex:(NSUInteger)index {
    
    NSString *titleStr = nil;
    if (index == 0) {
        titleStr = @"즐겨찾기";
    }
    else if (index == 1) {
        titleStr = @"전체";
    }
    else {
        titleStr = [NSString stringWithFormat:@"그룹(%@)", [[NSUserDefaults standardUserDefaults] objectForKey:EntityApointGroupName]];
    }
    
    UIButton *btn = [self makeTabButton:titleStr];
    return btn;
}

- (UIButton *)makeTabButton:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    
    [btn setTitleColor:RGB(137, 137, 137) forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [btn setTitleColor:RGB(33, 170, 164) forState:UIControlStateSelected];
    
    return btn;
}

- (NSUInteger)numberOfTabsForTabContainer:(TabContainerController *)tabContainer {
    return 3;
}

- (CGFloat)heightForTabInTabContainer:(TabContainerController *)tabContainer heightComponent:(TabComponentHeight)component {
    if (component == TabButtonHeight) {
        return 30;
    }
    else {
        return 1;
    }
}

- (UIColor *)tabContainer:(TabContainerController *)tabContainer colorForComponent:(TabComponentColor)component {
    if (component == TCIndicatorColor) {
        return RGB(33, 170, 164);
    }
    else if (component == TCIndicatorDefaultColor) {
        return RGB(216, 216, 216);
    }
    return nil;
}

- (void)tabContainer:(TabContainerController *)tabContainer didChangeTabToIndex:(NSUInteger)index {
    NSLog(@"hck : %ld", index);
    [_tfSearch resignFirstResponder];

    if (index == 0) {
        [_favoriteListVC reloadData];
    }
    else if (index == 1) {
        [_totalListVC reloadData];
    }
    else {
        [_groupListVC reloadData];
    }
}

#pragma mark PopupListViewControllerDelegate
- (void)popupListViewController:(UIViewController *)vc type:(PopupListType)type dataIndex:(NSInteger)dataIndex selecteData:(id)data btnIndex:(NSInteger)btnIndex {
    
    if (type == PopupListTypeDefault && btnIndex < 0) {
        NSString *groupName = data;
        NSLog(@"groupname = %@", groupName);
        NSString *title = [NSString stringWithFormat:@"그룹(%@)", groupName];
        [_tabController setButtonTitle:title btnIndex:2];
        [[NSUserDefaults standardUserDefaults] setObject:groupName forKey:EntityApointGroupName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (_tabController.activeTabIndex == 2) {
            [_groupListVC reloadData];
        }
    }
    
    [vc dismissViewControllerAnimated:NO completion:nil];
}
@end
