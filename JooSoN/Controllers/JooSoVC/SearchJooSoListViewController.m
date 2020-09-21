//
//  SearchJooSoListViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/28.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "SearchJooSoListViewController.h"
#import "JooSoCell.h"
#import "NSString+Utility.h"
#import "CallkitController.h"
#import "DBManager.h"
#import "NfcViewController.h"

@interface SearchJooSoListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CallkitControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnComplete;

@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderTitle;

@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *keyboardDown;

@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, strong) NSString *searchStr;
@property (nonatomic, strong) JooSo *selJooso;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;


@end

@implementation SearchJooSoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblView.tableHeaderView = _headerView;
    _tblView.tableFooterView = _footerView;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    _tblView.estimatedRowHeight = 60.0;
    
    _tfSearch.inputAccessoryView = _accessoryView;
    [_btnBack setTitle:self.title forState:UIControlStateNormal];
    self.title = nil;
    if (_viewType == SearchViewTypeDefault) {
        _btnComplete.hidden = YES;
    }
    else if (_viewType == SearchViewTypeSelect
             || _viewType == SearchViewTypeOption) {
        self.arrSelectedJooso = [NSMutableArray array];
    }
    
    self.arrCallState = [NSMutableArray array];
    self.arrData = [NSMutableArray arrayWithArray:_arrOrigin];
    [self refreshHederTitle];
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
    [self.tblView reloadData];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)reloadData {
    [self.arrData setArray:_arrOrigin];
    [self.tblView reloadData];
}
- (void)refreshHederTitle {
    NSString *countStr = [NSString stringWithFormat:@"%ld", _arrData.count];
    
    _lbHeaderTitle.text = [NSString stringWithFormat:@"Total (%@ 명)", [countStr addNumberFormater]];
}

- (void)setSearchText {
    NSLog(@"%@", _searchStr);
    
    if (_searchStr.length > 0) {
        [_arrData removeAllObjects];
        if ([_searchStr isNumeric]) {
            for (JooSo *jooso in _arrOrigin) {
                if ([[jooso getMainPhone] containsString:_searchStr]) {
                    [_arrData addObject:jooso];
                }
            }
        }
        else {
            for (JooSo *jooso in _arrOrigin) {
                
                if ([jooso.name containsString:_searchStr]) {
                    [_arrData addObject:jooso];
                }
            }
        }
    }
    else {
        [_arrData setArray:_arrOrigin];
    }
    
    [self refreshHederTitle];
    [self.tblView reloadData];
}

- (IBAction)textFieldEdtingchanged:(UITextField *)sender {
    self.searchStr = sender.text;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(setSearchText) object:nil];
    
    [self performSelector:@selector(setSearchText) withObject:nil afterDelay:0.2];
    
}

- (IBAction)onClickedButtonAction:(id)sender {
    [self.view endEditing:YES];
    if (sender == _btnBack) {
        
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _keyboardDown) {
        [self.view endEditing:YES];
    }
    else if (sender == _btnComplete) {
        if ([self.delegate respondsToSelector:@selector(searchListViewCheckedList:)]) {
            [_delegate searchListViewCheckedList:_arrSelectedJooso];
        }
        [self.navigationController popViewControllerAnimated:NO];
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
        if (_viewType == SearchViewTypeSelect
            || _viewType == SearchViewTypeOption) {
            cell.cellType = CellTypeSelect;
        }
        else {
            cell.cellType = CellTypeDefault;
        }
    }
    
    JooSo *jooso = [_arrData objectAtIndex:indexPath.row];
    if ([_arrSelectedJooso containsObject:jooso]) {
        [cell configurationData:jooso isChecked:YES];
    }
    else {
        [cell configurationData:jooso isChecked:NO];
    }
    
    
    [cell setOnBtnTouchUpInside:^(CellActionType actionType, JooSo *jooso, id data) {
        self.selJooso = jooso;
        
        NSString *url = @"";
        if (actionType == CellActionCall) {
            url = [NSString stringWithFormat:@"tel://%@", [jooso getMainPhone]];
            self.callType = @"1";
            [[AppDelegate instance] openSchemeUrl:url];
        }
        else if (actionType == CellActionSms) {
            url = [NSString stringWithFormat:@"sms://%@", [jooso getMainPhone]];
            [[AppDelegate instance] openSchemeUrl:url];
        }
        else if (actionType == CellActionCheck) {
            if (self.viewType == SearchViewTypeSelect) {
                if ([self.arrSelectedJooso containsObject:jooso]) {
                    [self.arrSelectedJooso removeObject:jooso];
                }
                else {
                    [self.arrSelectedJooso addObject:jooso];
                }
            }
            else if (self.viewType == SearchViewTypeOption) {
                [self.arrSelectedJooso removeAllObjects];
                [self.arrSelectedJooso addObject:jooso];
                [self.tblView reloadData];
            }
        }
        else if (actionType == CellActionNfc) {
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.x = self.selJooso.geoLng;
            info.y = self.selJooso.geoLat;
            info.jibun_address = self.selJooso.address;
            info.road_address = self.selJooso.roadAddress;
            info.name = self.selJooso.placeName;
            vc.passPlaceInfo = info;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (actionType == CellActionNavi) {
            NSString *selMapId = AppDelegate.instance.selMapId;
            if ([selMapId isEqualToString:MapIdNaver]) {
                url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", jooso.geoLat, jooso.geoLng, jooso.address, [[NSBundle mainBundle] bundleIdentifier]];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                [[AppDelegate instance] openSchemeUrl:url];
            }
            else if ([selMapId isEqualToString:MapIdGoogle]) {
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", jooso.address, jooso.geoLat, jooso.geoLng];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            }

        }
    }];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selJooso = [_arrData objectAtIndex:indexPath.row];
    if (_viewType == SearchViewTypeDefault) {
        NSString *url = [NSString stringWithFormat:@"tel://%@", [_selJooso getMainPhone]];
        _callType = @"1";
        [[AppDelegate instance] openSchemeUrl:url];
    }
    else if (_viewType == SearchViewTypeSelect) {
        if ([_arrSelectedJooso containsObject:_selJooso]) {
            [_arrSelectedJooso removeObject:_selJooso];
        }
        else {
            [_arrSelectedJooso addObject:_selJooso];
        }
        [self.tblView reloadData];
    }
    else if (_viewType == SearchViewTypeOption) {
        [_arrSelectedJooso removeAllObjects];
        [_arrSelectedJooso addObject:_selJooso];
        [self.tblView reloadData];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"SearchJooSoListViewCon %@", state);
    
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        NSDate *curDate = [NSDate date];
        if (_selJooso != nil) {
            
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
            
            
            [param setObject:_selJooso.name forKey:@"name"];
            [param setObject:[_selJooso getMainPhone]  forKey:@"phoneNumber"];
            [param setObject:callState forKey:@"callState"];
            [param setObject:_callType forKey:@"callType"];
            [param setObject:[NSDate date] forKey:@"createDate"];
            [param setObject:[NSNumber numberWithDouble:takeCalling] forKey:@"takeCalling"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"callCnt"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"historyType"];
            [param setObject:[NSNumber numberWithFloat:_selJooso.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithFloat:_selJooso.geoLng] forKey:@"geoLng"];
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

@end
