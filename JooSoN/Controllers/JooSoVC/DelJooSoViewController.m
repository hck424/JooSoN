//
//  DelJooSoViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "DelJooSoViewController.h"
#import "SearchJooSoListViewController.h"
#import "DBManager.h"
#import "UIView+Toast.h"
#import "HAlertView.h"
#import "NSString+Utility.h"
#import "ContactsManager.h"

@interface DelJooSoViewController () <SearchJooSoListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) SearchJooSoListViewController *searchJooSoListVC;
@property (nonatomic, strong) ContactsManager *contactsManager;

@end

@implementation DelJooSoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
//    - (void)myAddChildViewController:(UIViewController *)childController {
//        [self addChildViewController:childController]; //add the child on childViewControllers array
//        [childController willMoveToParentViewController:self]; //viewWillAppear on childViewController
//        [self.view addSubview:childController.view]; //add childView whenever you want
//        [self addConstraint:childController.view];
//        [childController didMoveToParentViewController:self];
//    }
//
//    - (void)myRemoveChildViewController:(UIViewController *)viewController{
//        [viewController willMoveToParentViewController:nil];
//        [viewController.view removeFromSuperview];
//        [viewController removeFromParentViewController];
//    }
    
    [self addChildJooSoSearchViewController];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestTotalJosoList];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)requestTotalJosoList {
    
//    __weak typeof (self) weakSelf = self;
    [[DBManager instance] getAllJooSo:^(NSArray *arrData) {
        [self.arrData setArray:arrData];
        self.searchJooSoListVC.arrOrigin = self.arrData;
        [self.searchJooSoListVC reloadData];
    } fail:^(NSError *error) {
        
    }];
}

- (void)addChildJooSoSearchViewController {
    self.searchJooSoListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchJooSoListViewController"];
    _searchJooSoListVC.viewType = SearchViewTypeSelect;
    _searchJooSoListVC.delegate = self;
    _searchJooSoListVC.view.frame = _contentView.bounds;
    _searchJooSoListVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchJooSoListVC.arrOrigin = _arrData;
    [self addChildViewController:_searchJooSoListVC];
    [_searchJooSoListVC willMoveToParentViewController:self];
    [_contentView addSubview:_searchJooSoListVC.view];
    
    [_searchJooSoListVC didMoveToParentViewController:self];
    
}

- (IBAction)onClickedButtonAction:(id)sender {
    
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == _btnDel) {
        if (_searchJooSoListVC.arrSelectedJooso.count == 0) {
            [self.view makeToast:@"삭제할 연락처를 선택해주세요" duration:0.5 position:CSToastPositionTop];
            return;
        }
        
        
        [HAlertView alertShowWithTitle:@"선택된 연락처 삭제" message:@"정말 삭제하시겠습니까?" btnTitles:@[@"삭제", @"취소"] alertBlock:^(NSInteger index) {
            if (index == 0) {
                
                
                for (JooSo *jooso in self.searchJooSoListVC.arrSelectedJooso) {
                    
                    NSString *phoneNumber = [jooso getMainPhone];
                    phoneNumber = [phoneNumber delPhoneFormater];
                    NSString *name = jooso.name;
                    
                    name = [name isEqual:[NSNull null]]? @"" : name;
                    NSMutableDictionary *param = [NSMutableDictionary dictionary];
                    
                    [param setObject:name forKey:@"name"];
                    if (phoneNumber != nil) {
                        [param setObject:phoneNumber forKey:@"phoneNumber"];
                    }
                    
                    if (phoneNumber.length > 0) {
                        if (self.contactsManager == nil) {
                            self.contactsManager = [[ContactsManager alloc] init];
                        }
                        
                        //전화번호부 삭제
                        [self.contactsManager deleteAddressBook:param completion:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"success delete jooso addressbook");
                            }
                            else {
                                NSLog(@"error: delte jooso address book> %@", error);
                            }
                        }];
                    }
                    
                    //로컬디비 삭제
                    [[DBManager instance] deleteJooSo:jooso success:nil fail:nil];
                }
                
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
        
    }
}

@end
