//
//  PopupListViewController.m
//  Hanpass
//
//  Created by 김학철 on 2020/07/14.
//  Copyright © 2020 hanpass. All rights reserved.
//

#import "BottomPopupViewController.h"
#import "Utility.h"
#import "UITableView+Utility.h"
#import "MapSearchResultCell.h"

@interface BottomPopupViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIStackView *svContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnFullClose;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIStackView *svTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTblView;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo2;

@property (nonatomic, assign) BottomPopupType type;
@property (nonatomic, strong) NSString *popupTitle;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSArray *originData;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, copy) void (^completion)(UIViewController *vcs, id selData, MapCellAction action);

@end

@implementation BottomPopupViewController

- (instancetype)initWidthType:(BottomPopupType)type title:(NSString *)title data:(NSArray *)data keys:(NSArray *)keys completion:(void (^)(UIViewController *vcs, id selData, MapCellAction action))completion {
    if (self = [self initWithNibName:@"BottomPopupViewController" bundle:nil]) {
        self.type = type;
        self.popupTitle = title;
        self.originData = data;
        self.keys = keys;
        self.completion = completion;
        
        //default setting
        self.showTopSeperator = NO;
        self.showSearchBar = NO;
        self.contentInset = UIEdgeInsetsMake(25, 0, 0, 0);
        self.showTableViewSeperator = NO;
        self.enableBgTouchClose = YES;
        self.showAnimation = NO;
        self.dismissAnimation = NO;
        self.animationDuration = 0.15;
        self.fontText = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        self.fontSubText = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        self.colorText = RGB(36, 36, 36);
        self.colorSubText = RGB(170, 170, 170);
        self.sizeThumnail = CGSizeMake(48.0, 48.0);
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [NSMutableArray arrayWithArray:_originData];
    [self decorationUi];
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

- (void)decorationUi {
    
    if (@available(iOS 11.0, *)) {
        _bgView.layer.cornerRadius = 20.0f;
        _bgView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner;
    }
    
    [_svContainer setLayoutMarginsRelativeArrangement:YES];
    _svContainer.layoutMargins = _contentInset;
    
    if (_enableBgTouchClose == NO) {
        _btnFullClose.userInteractionEnabled = NO;
    }
    
    _tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_showTableViewSeperator) {
        _tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    _tblView.estimatedRowHeight = 70.0;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblView.frame.size.width, 34)];
    _tblView.tableFooterView = footerView;
    
    _tblView.delegate = self;
    _tblView.dataSource = self;
    
    if (_data.count > 0) {
        _lbInfo.text = [NSString stringWithFormat:@"총 %ld건의 검색결과가 있습니다." , _data.count];
    }
    else {
        _lbInfo.text = @"검색결과가 없습니다.";
    }
    _lbInfo2.text = _popupTitle;
    
    [_tblView reloadData:^{
        [self.view layoutIfNeeded];
        
        self.heightTblView.constant = self.tblView.contentSize.height;
    
        if (self.showAnimation) {
            self.bottomContainer.constant = -self.bgView.frame.size.height;
            
            [UIView animateWithDuration:0.0 animations:^{
                self.btnFullClose.alpha = 0.0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.bottomContainer.constant = 0.0;
                [UIView animateWithDuration:self.animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.btnFullClose.alpha = 1.0;
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    }];
}

//FIXME:: CustomActions
- (IBAction)onClickedButtonActions:(UIButton *)sender {
    if (sender == _btnFullClose || sender == _btnClose) {
        [self dismissProcess:nil indexPath:nil];
    }
}

#pragma mark - UITalbeViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapSearchResultCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchResultCell" owner:nil options:nil].firstObject;
    }
    
    PlaceInfo *info = [_data objectAtIndex:indexPath.row];
    [cell configurationData:info];
    [cell setOnTouchUpInSideAction:^(MapCellAction action, PlaceInfo * _Nonnull data) {
        if (self.completion) {
            self.completion(self, data, action);
        }
    }];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == BottomPopupTypeMapSearch) {
        PlaceInfo *info = [_data objectAtIndex:indexPath.row];
        if (self.completion) {
            self.completion(self, info, MapCellActionDefault);
        }
    }
}

- (void)dismissProcess:(NSDictionary *)itemDic indexPath:(NSIndexPath *)indexPath {
    if (_dismissAnimation) {
        [self.view layoutIfNeeded];
        self.bottomContainer.constant = -self.bgView.frame.size.height;
        
        [UIView animateWithDuration:_animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
            self.btnFullClose.alpha = 0;
        } completion:^(BOOL finished) {
            self.completion(self, itemDic, -1);
        }];
    }
    else {
        self.completion(self, itemDic, -1);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - NotificationHandler
- (void)notificationHandler:(NSNotification *)notification {
    
    CGFloat heightKeyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        
        self.bottomContainer.constant = heightKeyboard;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.bottomContainer.constant = 0;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}
@end
