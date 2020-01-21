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
#import "SceneDelegate.h"

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource, CallkitControllerDelegate>
@property (weak, nonatomic) IBOutlet HTextField *textField;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;

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
        [_tblView reloadData];
    }
    else {
        _tblView.hidden = YES;
    }
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
            [[SceneDelegate instance] openSchemeUrl:url];
        }
        else if (action == HistoryCellActionSms) {
            NSString *url = [NSString stringWithFormat:@"sms://%@" ,hisory.phoneNumber];
            [[SceneDelegate instance] openSchemeUrl:url];
        }
        else if (action == HistoryCellActionNavi) {
            NSString *url = nil;
            NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
        
            if ([selMapId isEqualToString:MapIdNaver]) {
                url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selHistory.geoLat, self.selHistory.geoLng, self.selHistory.address, [[NSBundle mainBundle] bundleIdentifier]];
            }
            else if ([selMapId isEqualToString:MapIdGoogle]) {
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", self.selHistory.address, self.selHistory.geoLat, self.selHistory.geoLng];
            }
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            if (url.length > 0) {
                [[SceneDelegate instance] openSchemeUrl:url];
            }
        }
        else if (action == HistoryCellActionNfc) {
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.jibun_address = self.selHistory.address;
            info.x = self.selHistory.geoLng;
            info.y = self.selHistory.geoLat;
            info.name = self.selHistory.address;
            
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            vc.passPlaceInfo = info;
            [[SceneDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
    }];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    NSString *secTitle = [[_arrData objectAtIndex:section] objectForKey:@"sec_title"];
    headerView.lbTitle.text = secTitle;
    
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
        vc.passJooso = [arrData firstObject];
        [[SceneDelegate instance].rootNavigationController pushViewController:vc animated:NO];
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
            [param setObject:[NSNumber numberWithFloat:_selHistory.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithFloat:_selHistory.geoLng] forKey:@"geoLng"];
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
