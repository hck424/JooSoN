//
//  HistoryViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "TableHeaderView.h"
#import "DBManager.h"
#import "NSString+Utility.h"
#import "CallkitController.h"
#import "InfoJooSoViewController.h"
#import "ContactsManager.h"
#import "PlaceInfo.h"
#import "NfcViewController.h"
#import "UIView+Toast.h"
#import "HAlertView.h"

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource, CallkitControllerDelegate>
@property (weak, nonatomic) IBOutlet HTextField *textField;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (nonatomic, strong) NSMutableArray *arrOrigin;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, strong) History *selHistory;
@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    self.arrOrigin = [NSMutableArray array];
    self.arrCallState = [NSMutableArray array];
    
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
    _tblView.allowsSelection = YES;
    _tblView.tableFooterView = _footerView;
    _textField.inputAccessoryView = _accessoryView;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDate];
    self.textField.text = @"";
}

- (void)reloadDate {
    
    __weak typeof(self) weakSelf = self;
    
    [[DBManager instance] getAllHistory:^(NSArray *arrData) {
        [self.arrOrigin setArray:arrData];
        
        [weakSelf makeSectionData:arrData];
        
    } fail:^(NSError *error) {
        NSLog(@"error: history all list => %@", error.localizedDescription);
    }];
}

- (void)setSearchText:(NSString *)searchTxt {
    NSLog(@"%@", searchTxt);
    NSMutableArray *arrSeach = [NSMutableArray array];
    if ([searchTxt isNumeric]) {
        for (History *history in _arrOrigin) {
            if ([history.phoneNumber containsString:searchTxt]) {
                [arrSeach addObject:history];
            }
        }
    }
    else {
        for (History *history in _arrOrigin) {
            if ([history.name containsString:searchTxt]) {
                [arrSeach addObject:history];
            }
        }
    }
    
    if (searchTxt.length == 0) {
        [self makeSectionData:_arrOrigin];
    }
    else {
        [self makeSectionData:arrSeach];
    }
}
#pragma mark - UItextField Action
- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    [self setSearchText:sender.text];
}

#pragma mark - Clicked Button action
- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnKeyboardDown) {
        [self.view endEditing:YES];
    }
    else if (sender == _btnMic) {
        [SpeechAlertView showWithTitle:@"JooSoN" completion:^(NSString * _Nonnull result) {
            
            if (result.length > 0) {
                self.textField.text = result;
                if (self.arrData.count > 0) {
                    [self setSearchText:result];
                }
            }
        }];
    }
}

- (void)makeSectionData:(NSArray *)arrSearch {
    [_arrData removeAllObjects];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    df.dateFormat = @"yyyy.MM.dd";
    
    NSString *preDateStr = nil;
    NSMutableArray *arrSection = nil;
    
    for (History *history in arrSearch) {
        NSDate *date = history.createDate;
        NSString *curDateStr = [df stringFromDate:date];
        if ([preDateStr isEqualToString:curDateStr] == NO) {
            
            arrSection = [NSMutableArray array];
            NSMutableDictionary *sectionDic = [NSMutableDictionary dictionary];
            [sectionDic setObject:curDateStr forKey:@"sec_title"];
            [sectionDic setObject:arrSection forKey:@"sec_list"];
            [_arrData addObject:sectionDic];
        }
        
        [arrSection addObject:history];
        
        preDateStr = curDateStr;
    }
    
    if (_arrData.count > 0) {
        _tblView.hidden = NO;
    }
    else {
        _tblView.hidden = YES;
    }
    [_tblView reloadData];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_arrData objectAtIndex:section] objectForKey:@"sec_list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:self     options:nil].firstObject;
    }
    
    History *hisory = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    
    [cell configurationData:hisory];
    [cell setTouchUpInsideBtnAction:^(HistoryCellAction action, id data) {
        self.selHistory = (History *)data;
        
        if (action == HistoryCellActionCall) {
            NSString *url = [NSString stringWithFormat:@"tel://%@" ,hisory.phoneNumber];
            [[AppDelegate instance] openSchemeUrl:url];
        }
        else if (action == HistoryCellActionSms) {
            NSString *url = [NSString stringWithFormat:@"sms://%@" ,hisory.phoneNumber];
            [[AppDelegate instance] openSchemeUrl:url];
            [self saveHisotryWithHistory:self.selHistory type:1];
        }
        else if (action == HistoryCellActionNavi) {
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.jibun_address = self.selHistory.address;
            info.x = self.selHistory.geoLat;
            info.y = self.selHistory.geoLng;
            info.name = self.selHistory.address;
            
            NSString *url = [self getNaviUrlWithPalceInfo:info];
            
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                if (success) {
                    [self saveHisotryWithPlaceInfo:info type:4];
                }
                else {
                    [self.view makeToast:@"지도를 열수 없습니다."];
                }
            }];
        }
        else if (action == HistoryCellActionNfc) {
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.jibun_address = self.selHistory.address;
            info.x = self.selHistory.geoLat;
            info.y = self.selHistory.geoLng;
            info.name = self.selHistory.address;
            
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            vc.passPlaceInfo = info;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
    }];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    NSString *secTitle = [[_arrData objectAtIndex:section] objectForKey:@"sec_title"];
    headerView.lbTitle.text = secTitle;
    headerView.type = TableHeaderViewTypeDelete;
    NSArray *arrSec = [[_arrData objectAtIndex:section] objectForKey:@"sec_list"];
    headerView.data = arrSec;
    
    [headerView setOnTouchupInsideAction:^(id data, NSInteger actionIndex) {
        [HAlertView alertShowMsgWithCancelAndOkAction:@"해당 날짜에 기록을 지우시겠습니까?" alertBlock:^(NSInteger index) {
            if (index == 1) {
                if (data != nil && [data isKindOfClass:[NSArray class]]) {
                    NSArray *arrSec = data;
                    for (History *item in arrSec) {
                        [[DBManager instance] deleteHistory:item success:nil fail:nil];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self reloadDate];
                    });
                }
            }
        }];
    }];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSMutableArray *arrSec = [[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"];
        History *history = [arrSec objectAtIndex:indexPath.row];
        if (history != nil) {
            [arrSec removeObject:history];
        }

        if (arrSec.count == 0) {
            [_arrData removeObjectAtIndex:indexPath.section];
            _tblView.hidden = YES;
        }
        else {
            _tblView.hidden = NO;
        }

        [self.tblView reloadData];

        [[DBManager instance] deleteHistory:history success:^{
            NSLog(@"success : delete history db");
        } fail:^(NSError *error) {
            NSLog(@"error: not delete history db > %@", error.localizedDescription);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    History *history = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    [[DBManager instance] findJoosoWithPhoneNumber:history.phoneNumber name:history.name success:^(NSArray *arrData) {
        InfoJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoJooSoViewController"];
        if (arrData.count > 0) {
            vc.passJooso = arrData.firstObject;
        }
        else {
            vc.passHistory = history;
        }
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    } fail:^(NSError *error) {
        NSLog(@"error: not find jooso > %@", error);
    }];
}

#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"%@: %@", NSStringFromClass([self class]), state);
    
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        NSDate *curDate = [NSDate date];
        if (_selHistory != nil) {
            
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
            
            NSString *name = _selHistory.name;
            [param setObject:_selHistory.phoneNumber  forKey:@"phoneNumber"];
            [param setObject:name forKey:@"name"];
            [param setObject:callState forKey:@"callState"];
            [param setObject:_callType forKey:@"callType"];
            [param setObject:[NSDate date] forKey:@"createDate"];
            [param setObject:[NSNumber numberWithDouble:takeCalling] forKey:@"takeCalling"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"callCnt"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"historyType"];
            [param setObject:[NSNumber numberWithDouble:_selHistory.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:_selHistory.geoLng] forKey:@"geoLng"];
            if (_selHistory.address != nil) {
                [param setObject:_selHistory.address forKeyedSubscript:@"address"];
            }
            
            [[DBManager instance] insertHistory:param success:^{
                NSLog(@"success: insert history db");
            } fail:^(NSError *error) {
                NSLog(@"error : history table insert error > %@", error.localizedDescription);
            }];
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
