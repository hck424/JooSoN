//
//  PopupListViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "PopupListViewController.h"
#import "PopupCell.h"
#import "AppDelegate.h"

@interface PopupListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *topSeperator;
@property (weak, nonatomic) IBOutlet UIStackView *svTitle;
@property (weak, nonatomic) IBOutlet UIStackView *svButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIStackView *svEdting;
@property (weak, nonatomic) IBOutlet UILabel *lbEdtingTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfEdting;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainer;

@property (nonatomic, strong) NSString *edtingText;
@end

@implementation PopupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.estimatedRowHeight = 40;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    if (_popupTitle.length == 0) {
        _svTitle.hidden = YES;
        _topSeperator.hidden = YES;
    }
    else {
        _lbTitle.text = _popupTitle;
    }
    
    if (_popupType == PopupListTypeEding) {
        _svEdting.hidden = NO;
        if (_endingFieldTitle.length > 0) {
            _lbEdtingTitle.hidden = NO;
            _lbEdtingTitle.text = _endingFieldTitle;
        }
        else {
            _lbEdtingTitle.hidden = YES;
        }
    }
    else {
        _svEdting.hidden = YES;
    }

    if (_arrBtnTitle.count > 0) {
        for (NSInteger i = 0; i < _arrBtnTitle.count; i++) {
            
            NSString *title = [_arrBtnTitle objectAtIndex:i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            btn.adjustsImageWhenHighlighted = NO;
            if (_arrBtnTitleColor.count > 0 && i < _arrBtnTitleColor.count) {
                UIColor *color = [_arrBtnTitleColor objectAtIndex:i];
                [btn setTitleColor:color forState:UIControlStateNormal];
            }
            else {
                [btn setTitleColor:RGB(125, 125, 125) forState:UIControlStateNormal];
            }
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(onClickedButton:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 100 + i;
            [_svButton addArrangedSubview:btn];
    
        }
    }
    else {
        _svButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGSize size = [self preferredContentSize];
    _heightTableView.constant = size.height;
    [self.view layoutIfNeeded];
    [_shadowView addShadow:CGSizeMake(3, 3) color:RGBA(0, 0, 0, 0.5) radius:5 opacity:0.5];
    [_containerView roundCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:20];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (IBAction)singleTapGesture:(id)sender {
//    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - textfiled action
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {
    self.edtingText = sender.text;
}

#pragma mark - UIbutton action
- (void)onClickedButton:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    NSString *data = nil;
    
    if (_popupType == PopupListTypeEding) {
        data = _edtingText;
    }
    
    if ([self.delegate respondsToSelector:@selector(popupListViewController:type:dataIndex:selecteData:btnIndex:)]) {
        [_delegate popupListViewController:self type:_popupType dataIndex:-1 selecteData:data btnIndex:index];
    }
}

- (CGSize)preferredContentSize {
    [self.tblView layoutIfNeeded];
    return self.tblView.contentSize;
}
#pragma - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopupCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PopupCell" owner:self options:nil].firstObject;
    }
    NSString *titleStr = [_arrData objectAtIndex:indexPath.row];
    cell.lbTitle.text = titleStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selData = [_arrData objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(popupListViewController:type:dataIndex:selecteData:btnIndex:)]) {
        [_delegate popupListViewController:self type:_popupType dataIndex:indexPath.row selecteData:selData btnIndex:-1];
    }
}

#pragma mark - notification handler
- (void)notificationHandler:(NSNotification *)notification {

    CGFloat heightKeyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat aniDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        [UIView animateWithDuration:aniDuration animations:^{
            self.bottomContainer.constant = heightKeyboard;
        }];
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        [UIView animateWithDuration:aniDuration animations:^{
            self.bottomContainer.constant = 0;
        }];
        
    }
}

@end
