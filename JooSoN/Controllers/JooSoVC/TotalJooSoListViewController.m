//
//  TotalJooSoListViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "TotalJooSoListViewController.h"
#import "TableHeaderView.h"
#import "JooSoCell.h"
#import "DBManager.h"
#import "NSString+Utility.h"
#import "CallkitController.h"
#import "Utility.h"
#import "InfoJooSoViewController.h"
#import "NfcViewController.h"
#import "UIView+Toast.h"

@interface TotalJooSoListViewController () <UITableViewDelegate, UITableViewDataSource, CallkitControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *lbEmpty;

@property (nonatomic, strong) NSMutableArray *arrOrigin;
@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, strong) NSString *searchStr;
@property (nonatomic, strong) JooSo *selJooso;
@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;
@end

@implementation TotalJooSoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    self.arrOrigin = [NSMutableArray array];
    self.arrCallState = [NSMutableArray array];
    
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
    self.tblView.tableFooterView = _footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestGetAllContacts];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)reloadData {
    self.searchStr = nil;
    [self makeSectionData:_arrOrigin];
}

- (void)setSearchText:(NSString *)searchTxt {
    NSLog(@"%@", searchTxt);
    NSMutableArray *arrSeach = [NSMutableArray array];
    
    if ([searchTxt isNumeric]) {
        for (JooSo *jooso in _arrOrigin) {
            if ([[jooso getMainPhone] containsString:searchTxt]) {
                [arrSeach addObject:jooso];
            }
        }
    }
    else {
        for (JooSo *jooso in _arrOrigin) {
            if ([jooso.name containsString:searchTxt]) {
                [arrSeach addObject:jooso];
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

- (void)requestGetAllContacts {
    [[DBManager instance] getAllJooSo:^(NSArray *arrData) {
        if (arrData.count > 0) {
            self.tblView.hidden = NO;
            self.lbEmpty.hidden = YES;
            [self.arrOrigin setArray:arrData];
            [self makeSectionData:arrData];
        }
        else {
            self.tblView.hidden = YES;
            self.lbEmpty.hidden = NO;
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (void)makeSectionData:(NSArray *)arrData {
    
    NSString *preStr = @"";
    NSMutableArray *arrSec = nil;
    [_arrData removeAllObjects];
    
    for (JooSo *jooso in arrData) {
        
        NSString *curStr = [jooso.name alphabetHangul];
        if (curStr.length > 0 && [preStr isEqualToString:curStr] == NO) {

            arrSec = [NSMutableArray array];
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
            [tmpDic setObject:curStr forKey:@"sec_title"];
            [tmpDic setObject:arrSec forKey:@"sec_list"];
            [arrSec addObject:jooso];
            [self.arrData addObject:tmpDic];
        }
        else {
            [arrSec addObject:jooso];
        }
        preStr = curStr;
    }

    [self.tblView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [[[_arrData objectAtIndex:section] objectForKey:@"sec_list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JooSoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JooSoCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JooSoCell" owner:self options:nil].firstObject;
        cell.cellType = CellTypeDefault;
    }
    
    JooSo *jooso = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    
    [cell configurationData:jooso];
    
    [cell setOnBtnTouchUpInside:^(CellActionType actionType, JooSo *jooso, id data) {
        self.selJooso = jooso;
        NSString *url = @"";
        if (actionType == CellActionCall) {
            self.callType = @"1";
            url = [NSString stringWithFormat:@"tel://%@", [jooso getMainPhone]];
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                
            }];
        }
        else if (actionType == CellActionSms) {
            url = [NSString stringWithFormat:@"sms://%@", [jooso getMainPhone]];
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                [self saveHisotryWithJooso:self.selJooso type:1];
            }];
        }
        else if (actionType == CellActionNfc) {
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.x = self.selJooso.geoLat;
            info.y = self.selJooso.geoLng;
            info.jibun_address = self.selJooso.address;
            info.road_address = self.selJooso.roadAddress;
            info.name = self.selJooso.placeName;
            vc.passPlaceInfo = info;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (actionType == CellActionNavi) {
            
            PlaceInfo *info = [[PlaceInfo alloc] init];
            info.jibun_address = jooso.address;
            info.x = jooso.geoLat;
            info.y = jooso.geoLng;
            
            NSString *url = [self getNaviUrlWithPalceInfo:info];
            
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                if (success) {
                    [self saveHisotryWithJooso:jooso type:4];
                }
                else {
                    [self.view makeToast:@"설정된 지도앱을 열수 없습니다." duration:0.2 position:CSToastPositionTop];
                }
            }];
        }
    }];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    NSString *tmpTitle = [[_arrData objectAtIndex:section] objectForKey:@"sec_title"];
    headerView.lbTitle.text = tmpTitle;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JooSo *selJooso = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    
    InfoJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoJooSoViewController"];
    vc.passJooso = selJooso;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
}


#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"TotalJoosoListViewCon %@", state);
    
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


@end
