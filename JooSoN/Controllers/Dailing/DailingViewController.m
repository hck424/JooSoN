//
//  DailingViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "DailingViewController.h"
#import "NSString+Utility.h"
#import "NBAsYouTypeFormatter.h"
#import "Utility.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "AddJooSoViewController.h"
#import "SearchJooSoListViewController.h"
#import "CallkitController.h"
#import "CopyLabel.h"

@interface DailingViewController () <CallkitControllerDelegate, SearchJooSoListViewControllerDelegate>
@property (weak, nonatomic) IBOutlet CopyLabel *lbInputCall;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *arrNumberBtn;
@property (weak, nonatomic) IBOutlet UIView *safeBottomView;

@property (weak, nonatomic) IBOutlet UIButton *btnFace;
@property (weak, nonatomic) IBOutlet UIButton *btnSms;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureDel;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIStackView *svMoreContainer;
@property (strong, nonatomic) IBOutletCollection(BGStackView) NSArray *arrSvMore;
@property (weak, nonatomic) IBOutlet UIStackView *svBtnMore;

@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrOrigin;
@property (nonatomic, strong) NSMutableArray *arrSearch;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, strong) NBAsYouTypeFormatter *nbaFomater;

@property (nonatomic, strong) NSString *callType;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;

@property (nonatomic, strong) JooSo *selJooso;
@property (nonatomic, strong) NSString *selPhoneNumber;
@end

@implementation DailingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrOrigin = [NSMutableArray array];
    self.arrSearch = [NSMutableArray array];
    self.arrCallState = [NSMutableArray array];
    for (UIButton *btn in _arrNumberBtn) {
        [btn addTarget:self action:@selector(onClickedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.arrNumberBtn = [_arrNumberBtn sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    
    self.arrSvMore = [_arrSvMore sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    
    for (BGStackView *stView in _arrSvMore) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
        [stView addGestureRecognizer:tap];
    }
    _btnCall.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnFace.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnSms.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    _lbInputCall.layer.borderColor = UIColor.redColor.CGColor;
//    _lbInputCall.layer.borderWidth = 1.0;
    
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
    self.nbaFomater = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"KR"];
    
    _longPressGestureDel.minimumPressDuration = 0.5;
    
    if ([Utility isIphoneX]) {
        _safeBottomView.hidden = NO;
    }
    else {
        _safeBottomView.hidden = YES;
    }
    _svMoreContainer.hidden = YES;
    _btnAdd.hidden = YES;
    
    [self requestGetAllContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
    _btnCall.layer.cornerRadius = _btnCall.frame.size.height/2;
    _btnCall.layer.masksToBounds = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)requestGetAllContacts {
    [[DBManager instance] getAllJooSo:^(NSArray *arrData) {
        if (arrData.count > 0) {
            [self.arrOrigin setArray:arrData];
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (void)singleTapGesture:(UIGestureRecognizer *)sender {
    if ([sender.view isKindOfClass:[BGStackView class]]) {
        BGStackView *tmpView = (BGStackView *)sender.view;
        self.selJooso = tmpView.data;
        self.selPhoneNumber = nil;
        if ([_selJooso getMainPhone] != nil) {
            _lbInputCall.text = [_nbaFomater inputString:[_selJooso getMainPhone]];
        }
    }
}

- (IBAction)longPressGesture:(UIGestureRecognizer *)sender {
    if (sender == _longPressGestureDel
        && sender.state == UIGestureRecognizerStateChanged) {
        
        @try {
            if (_lbInputCall.text.length > 0) {
                NSString *tmpStr = [_lbInputCall.text substringToIndex:_lbInputCall.text.length - 1];
                NSString *oldStr = [tmpStr delPhoneFormater];
                NSString *newStr = [_nbaFomater inputString:oldStr];
                _lbInputCall.text = newStr;
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.callStackSymbols);
        }
    }
}

- (IBAction)onClickedButtonAction:(UIButton *)sender {
    if (sender.tag >= 100 && sender.tag <= 109) {
        NSInteger num = sender.tag - 100;
        NSString *oldTxt = [_lbInputCall.text delPhoneFormater];
        
        NSString *newStr = [oldTxt stringByAppendingFormat:@"%ld", (long)num];
        [self refreshMoreUiWithSearchStr:newStr];
        newStr = [_nbaFomater inputString:newStr];
        _lbInputCall.text = newStr;
        self.selJooso = nil;
    }
    else if (sender.tag == 110 || sender.tag == 111) {
        NSString *inputChar = @"";
        if (sender.tag == 110) {
            inputChar = @"*";
        } else {
            inputChar = @"#";
        }
        self.selJooso = nil;
        NSString *oldTxt = [_lbInputCall.text delPhoneFormater];
        NSString *newStr = [oldTxt stringByAppendingFormat:@"%@", inputChar];
        _lbInputCall.text = newStr;
    }
    else if (sender == _btnCall
             || sender == _btnFace) {
        self.selPhoneNumber = [_lbInputCall.text delPhoneFormater];
        
        if (_selPhoneNumber.length > 0) {
            NSString *url = @"";
            
            if (sender == _btnCall) {
                url = [NSString stringWithFormat:@"tel://%@", _selPhoneNumber];
                self.callType = @"1";
            }
            else if (sender == _btnFace) {
                url = [NSString stringWithFormat:@"facetime://%@", _selPhoneNumber];
                self.callType = @"2";
            }
            
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                            
            }];
        }
    }
    else if (sender == _btnSms) {
        self.selPhoneNumber = [_lbInputCall.text delPhoneFormater];
        if (_selPhoneNumber.length > 0) {
            NSString *url = [NSString stringWithFormat:@"sms://%@", _selPhoneNumber];
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                if (success) {
                    if (self.selJooso != nil) {
                        [self saveHisotryWithJooso:self.selJooso type:1];
                    }
                    else {
                        [self saveHisotryWithPhoneNumber:self.selPhoneNumber type:1];
                    }
                }
            }];
        }
    }
    else if (sender == _btnDel) {
        NSString *oldTxt = [_lbInputCall.text delPhoneFormater];
        NSString *newStr = @"";
        if (oldTxt.length > 0) {
            newStr = [oldTxt substringToIndex:oldTxt.length - 1];
        }
        [self refreshMoreUiWithSearchStr:newStr];
        newStr = [_nbaFomater inputString:newStr];
        _lbInputCall.text = newStr;
    }
    else if (sender == _btnAdd && _lbInputCall.text.length > 0) {
        __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"연락처 추가" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *actionNew = [UIAlertAction actionWithTitle:@"새 연락처 추가" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
            
            AddJooSoViewController *vc = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
            vc.passPhoneNumber = [weakSelf.lbInputCall.text delPhoneFormater];
            vc.viewType = ViewTypeAdd;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }];
        
        
        UIAlertAction *actionOld = [UIAlertAction actionWithTitle:@"기존 연락처에 추가" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
            SearchJooSoListViewController *vc = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"SearchJooSoListViewController"];
            vc.viewType = SearchViewTypeOption;
            vc.delegate = self;
            vc.arrOrigin = self.arrOrigin;
            vc.selPhoneNumber = [weakSelf.lbInputCall.text delPhoneFormater];
            vc.title = @"연락처 선택";
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }];
        
        [alert addAction:actionNew];
        [alert addAction:actionOld];
        [alert addAction:actionCancel];
        
        alert.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (sender == _btnMore) {
        SearchJooSoListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchJooSoListViewController"];
        vc.viewType = SearchViewTypeDefault;
        vc.arrOrigin = _arrSearch;
        vc.title = @"검색 결과";
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    }
}

- (NSArray *)getSearchArray:(NSString *)searchKey {
    NSMutableArray *arrSearch = [NSMutableArray array];
    for (JooSo *jooso in _arrOrigin) {
        if ([[[jooso getMainPhone] delPhoneFormater] containsString:[searchKey delPhoneFormater]]) {
            [arrSearch addObject:jooso];
        }
    }
    return arrSearch;
}

- (void)refreshMoreUiWithSearchStr:(NSString*)searchStr {
    if (searchStr.length == 0) {
        _svMoreContainer.hidden = YES;
        _btnAdd.hidden = YES;
    }
    else  {
        _btnAdd.hidden = NO;
        
        [self.arrSearch setArray:[self getSearchArray:searchStr]];
        
        if (_arrSearch.count == 0) {
            _svMoreContainer.hidden = YES;
        }
        else if (_arrSearch.count >= 3) {
            _svMoreContainer.hidden = NO;
            if (_arrSearch.count > 3) {
                _svBtnMore.hidden = NO;
                NSString *titleStr = [NSString stringWithFormat:@"%ld명 더보기", _arrSearch.count];
                [_btnMore setTitle:titleStr forState:UIControlStateNormal];
            }
            else {
                _svBtnMore.hidden = YES;
            }
            
            for (NSInteger i = 0; i < 3; i++) {
                BGStackView *sv = [_arrSvMore objectAtIndex:i];
                sv.hidden = NO;
                
                JooSo *jooso = [_arrSearch objectAtIndex:i];
                sv.data = jooso;

                UILabel *lbName = [sv viewWithTag:100];
                UILabel *lbPhoneNumber = [sv viewWithTag:200];
                lbName.text = jooso.name;

                NSString *resultStr = [[jooso getMainPhone] delPhoneFormater];
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:resultStr];
                [attr addAttribute:NSForegroundColorAttributeName value:RGB(36, 183, 179) range:[resultStr rangeOfString:searchStr]];
                lbPhoneNumber.attributedText = attr;
            }
        }
        else if (_arrSearch.count == 2) {
            _svMoreContainer.hidden = NO;
            _svBtnMore.hidden = YES;
            
            ((UIStackView *)[_arrSvMore lastObject]).hidden = YES;
            
            for (NSInteger i = 0; i < 2; i++) {
                BGStackView *sv = [_arrSvMore objectAtIndex:i];
                JooSo *jooso = [_arrSearch objectAtIndex:i];
                sv.data = jooso;

                UILabel *lbName = [sv viewWithTag:100];
                UILabel *lbPhoneNumber = [sv viewWithTag:200];
                lbName.text = jooso.name;

                NSString *resultStr = [[jooso getMainPhone] delPhoneFormater];
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:resultStr];
                [attr addAttribute:NSForegroundColorAttributeName value:RGB(36, 183, 179) range:[resultStr rangeOfString:searchStr]];
                lbPhoneNumber.attributedText = attr;
            }
        }
        else if (_arrSearch.count == 1) {
            _svMoreContainer.hidden = NO;
            _svBtnMore.hidden = YES;
            
            for (NSInteger i = _arrSvMore.count - 1; i >= 0; i--) {
                BGStackView *sv = [_arrSvMore objectAtIndex:i];
                
                if (i == 0) {
                    JooSo *jooso = [_arrSearch objectAtIndex:i];
                    sv.data = jooso;
                    
                    UILabel *lbName = [sv viewWithTag:100];
                    UILabel *lbPhoneNumber = [sv viewWithTag:200];
                    lbName.text = jooso.name;
                    
                    NSString *resultStr = [[jooso getMainPhone] delPhoneFormater];
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:resultStr];
                    [attr addAttribute:NSForegroundColorAttributeName value:RGB(36, 183, 179) range:[resultStr rangeOfString:searchStr]];
                    lbPhoneNumber.attributedText = attr;
                }
                else {
                    sv.hidden = YES;
                }
            }
        }
    }
}

#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"TotalJoosoListViewCon %@", state);
    
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        NSDate *curDate = [NSDate date];
        if (_selJooso != nil || _selPhoneNumber.length > 0) {
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            
            CGFloat takeCalling = 0.0;
            NSString *callState = @"";
            if (_arrCallState.count == 0) {
                //부재중
                callState =  @"1";
            }
            else if (_arrCallState.count == 1) {
                if ([[_arrCallState firstObject] isEqualToString:CALLING_STATE_DAILING]) {
                    callState = @"2";
                }
                else {
                    callState = @"3";
                }
            }
            else {
                //통화
                if ([[_arrCallState firstObject] isEqualToString:CALLING_STATE_DAILING]
                    && [[_arrCallState lastObject] isEqualToString:CALLING_STATE_CONNECTED]) {
                    callState = @"4";
                }
                else if ([[_arrCallState firstObject] isEqualToString:CALLING_STATE_INCOMING]
                         && [[_arrCallState lastObject] isEqualToString:CALLING_STATE_CONNECTED]) {
                    callState = @"5";
                }
                takeCalling = [curDate timeIntervalSince1970] - _callConectedTimeInterval;
            }
            
            NSString *name = nil;
            NSString *phoneNumber = nil;
            if (_selJooso != nil) {
                name = _selJooso.name;
                phoneNumber = [_selJooso getMainPhone];
            }
            else {
                phoneNumber = _selPhoneNumber;
            }
            name = name.length > 0? name : @"";
            [param setObject:name forKey:@"name"];
            [param setObject:phoneNumber forKey:@"phoneNumber"];
            [param setObject:callState forKey:@"callState"];
            [param setObject:_callType forKey:@"callType"];
            [param setObject:[NSDate date] forKey:@"createDate"];
            [param setObject:[NSNumber numberWithDouble:takeCalling] forKey:@"takeCalling"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"callCnt"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"historyType"];
            [param setObject:[NSNumber numberWithDouble:_selJooso.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:_selJooso.geoLng] forKey:@"geoLng"];
            if (_selJooso.address != nil) {
                [param setObject:_selJooso.address forKeyedSubscript:@"address"];
            }
            
            [[DBManager instance] insertHistory:param success:^{
                NSLog(@"success: insert history db");
            } fail:^(NSError *error) {
                NSLog(@"error : history table insert error > %@", error.localizedDescription);
            }];
            
            
            self.selJooso = nil;
        }
        [_arrCallState removeAllObjects];
    }
    else if ([state isEqualToString:CALLING_STATE_DAILING]) {
        [_arrCallState addObject:state];
    }
    else if ([state isEqualToString:CALLING_STATE_INCOMING]) {
        [_arrCallState addObject:state];
    }
    else if ([state isEqualToString:CALLING_STATE_CONNECTED]) {
        [_arrCallState addObject:state];
        self.callConectedTimeInterval = [[NSDate date] timeIntervalSince1970];
    }
}

#pragma mark - SearchListViewControllerDelegate
- (void)searchListViewCheckedList:(NSArray *)arrCheck {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (arrCheck.count > 0) {
            AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
            vc.viewType = ViewTypeModi;
            vc.passJooso = [arrCheck firstObject];
            vc.passPhoneNumber = [self.lbInputCall.text delPhoneFormater];
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
    });
}

@end
