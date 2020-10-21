//
//  FavoriteListViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "FavoriteListViewController.h"
#import "TableHeaderView.h"
#import "CallkitController.h"
#import "DBManager.h"
#import "JooSoCell.h"
#import "TableHeaderView.h"
#import "InfoJooSoViewController.h"
#import "NSString+Utility.h"
#import "NfcViewController.h"

@interface FavoriteListViewController () <CallkitControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *lbEmpty;
@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrOrigin;
@property (nonatomic, strong) JooSo *selJooso;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;


@end

@implementation FavoriteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    self.arrOrigin = [NSMutableArray array];
    self.arrCallState = [NSMutableArray array];
    
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
    _tblView.tableFooterView = _footerView;
    
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    headerView.lbTitle.text = @"숫자 & 기호";
    _tblView.tableHeaderView = headerView;
    
    _tblView.estimatedRowHeight = 50;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiNameCallState object:nil];
}

- (void)reloadData {
    __weak typeof (self) weakSelf = self;
    [[DBManager instance] getAllLike:^(NSArray *arrData) {
        if (arrData.count > 0) {
            self.tblView.hidden = NO;
            self.lbEmpty.hidden = YES;
            [self.arrOrigin setArray:arrData];
            [weakSelf makeSectionData:arrData];
        }
        else {
            self.tblView.hidden = YES;
            self.lbEmpty.hidden = NO;
        }
    } fail:^(NSError *error) {
        NSLog(@"error: get all like list > %@", error);
    }];
}

- (void)makeSectionData:(NSArray *)arr {
    [_arrData removeAllObjects];
    
    if (arr.count > 0) {
        [self.arrData setArray:arr];
    }
    
    [self.tblView reloadData];
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
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JooSoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JooSoCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JooSoCell" owner:self options:nil].firstObject;
    }
    
    JooSo *jooso = [_arrData objectAtIndex:indexPath.row];
    [cell configurationData:jooso];
    [cell setOnBtnTouchUpInside:^(CellActionType actionType, JooSo *jooso, id data) {
        self.selJooso = jooso;
        NSString *url = nil;
        if (actionType == CellActionCall) {
            url = [NSString stringWithFormat:@"tel://%@", [jooso getMainPhone]];
            self.callType = @"1";
        }
        else if (actionType == CellActionSms) {
            url = [NSString stringWithFormat:@"sms://%@", [jooso getMainPhone]];
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
            
            if ([AppDelegate.instance.selMapId isEqualToString:MapIdNaver]) {
                url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", jooso.geoLat, jooso.geoLng, jooso.address, [[NSBundle mainBundle] bundleIdentifier]];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            }
            else if ([AppDelegate.instance.selMapId isEqualToString:MapIdGoogle]) {
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", jooso.address, jooso.geoLat, jooso.geoLng];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            }
        }

        
        if (url.length > 0) {
            [[AppDelegate instance] openSchemeUrl:url];
        }
    }];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    headerView.lbTitle.text = @"숫자 & 기호";
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JooSo *jooso = [_arrData objectAtIndex:indexPath.row];
    InfoJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoJooSoViewController"];
    vc.passJooso = jooso;
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
