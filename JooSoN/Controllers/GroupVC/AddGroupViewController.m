//
//  AddGroupViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "AddGroupViewController.h"
#import "Utility.h"
#import "JooSoCell.h"
#import "DBManager.h"
#import "SearchJooSoListViewController.h"


@interface AddGroupViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SearchJooSoListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnAddJooso;
@property (weak, nonatomic) IBOutlet HTextField *tfGroup;
@property (weak, nonatomic) IBOutlet UIButton *btnSafety;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupCount;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIStackView *svNewGroup;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSString *selGroupName;

@end

@implementation AddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([Utility isIphoneX] == NO) {
        _btnSafety.hidden = YES;
    }
    [_btnBack setTitle:self.title forState:UIControlStateNormal];
    self.title = nil;
    
    self.arrData = [NSMutableArray array];
     
    _btnGroupCount.layer.cornerRadius = _btnGroupCount.frame.size.height/2;
    _tfGroup.inputAccessoryView = _accessoryView;
    
    if (_type == AddGroupTypeDefault) {
        _svNewGroup.hidden = YES;
        [_btnGroupCount setTitle:[NSString stringWithFormat:@"%lld 명", _passGroup.count] forState:UIControlStateNormal];
    }
    
    _tblView.tableFooterView = _footerView;
    _tblView.estimatedRowHeight = 60;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    if (_type == AddGroupTypeDefault && _passGroup != nil) {
        [self reloadData];
        self.selGroupName = _passGroup.name;
    }
    else {
        _tblView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillHideNotification object:nil];
    

   
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)reloadData {
    
    [[DBManager instance] getGroupNameJooSoList:_passGroup.name success:^(NSArray *arrData) {
        if (arrData.count > 0) {
            [self.arrData setArray:arrData];
            self.tblView.hidden = NO;
            [self.tblView reloadData];
        }
        else {
            self.tblView.hidden = YES;
        }
    
    } fail:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
#pragma mark - textField actions
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {
    self.selGroupName = sender.text;
}

#pragma mark - button actions
- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _btnKeyboardDown) {
        [_tfGroup resignFirstResponder];
    }
    else if (sender == _btnSave) {
        
        for (JooSo *js in _arrData) {
            js.groupName = _selGroupName;
            [[DBManager instance] updateWidthJooSo:js success:nil fail:nil];
        }
        
        if (_type == AddGroupTypeNew) {
            [[DBManager instance] insertGroupName:_tfGroup.text count:_arrData.count success:nil fail:nil];
        }
        else {
            _passGroup.count = _arrData.count;
            [[DBManager instance] updateGroupName:_passGroup success:nil fail:nil];
        }
       
        [self.navigationController popViewControllerAnimated:NO];
        
    }
    else if (sender == _btnAddJooso) {
        [[DBManager instance] getGroupNameJooSoList:@"NO" success:^(NSArray *arrData) {
            SearchJooSoListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchJooSoListViewController"];
            vc.viewType = SearchViewTypeSelect;
            vc.delegate = self;
            vc.title = @"연락처 선택";
            vc.arrOrigin = arrData;
            [self.navigationController pushViewController:vc animated:NO];
        } fail:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JooSoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JooSoCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JooSoCell" owner:self options:nil].firstObject;
        cell.cellType = CellTypeClose;
    }
    
    JooSo *js = [_arrData objectAtIndex:indexPath.row];
    [cell configurationData:js];
    
    [cell setOnBtnTouchUpInside:^(CellActionType actionType, JooSo *jooso, id data) {
        if (actionType == CellActionClose) {
            if (self.type == AddGroupTypeDefault) {
                jooso.groupName = @"";
                [[DBManager instance] updateWidthJooSo:jooso success:nil fail:nil];
                
                self.passGroup.count = self.passGroup.count - 1;
                [[DBManager instance] updateGroupName:self.passGroup success:nil fail:nil];
            }
            [self.arrData removeObject:jooso];
            [self.btnGroupCount setTitle:[NSString stringWithFormat:@"%ld 명", self.arrData.count] forState:UIControlStateNormal];
            [self.tblView reloadData];
        }
    }];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//jooso.groupName = @"";
//[[DBManager instance] updateWidthJooSo:jooso success:nil fail:nil];
//self.passGroup.count = self.passGroup.count - 1;
//[[DBManager instance] updateGroupName:self.passGroup success:nil fail:nil];

#pragma mark - notification handler
- (void)notificationHandler:(NSNotification *)notifiaction {
    
    CGFloat heightKeyboard = [[notifiaction.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [[notifiaction.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if ([notifiaction.name isEqualToString:UIKeyboardWillShowNotification]) {
        if ([Utility isIphoneX]) {
            heightKeyboard = heightKeyboard - 34;
        }
        [UIView animateWithDuration:duration animations:^{
            self.bottomConstraint.constant = heightKeyboard;
        }];
    }
    else if ([notifiaction.name isEqualToString:UIKeyboardWillHideNotification]) {
        [UIView animateWithDuration:duration animations:^{
            self.bottomConstraint.constant = 0;
        }];
    }
}

#pragma mark - SearchJooSoListViewControllerDelegate
- (void)searchListViewCheckedList:(NSArray *)arrCheck {
    if (arrCheck.count > 0) {
        [self.arrData addObjectsFromArray:arrCheck];
        [self.btnGroupCount setTitle:[NSString stringWithFormat:@"%ld 명", self.arrData.count] forState:UIControlStateNormal];
        _tblView.hidden = NO;
        [_tblView reloadData];
    }
}
@end
