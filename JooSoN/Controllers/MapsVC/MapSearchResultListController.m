//
//  MapSearchResultListController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchResultListController.h"
#import "MapSearchResultCell.h"
#import "UIView+Utility.h"
#import "AddJooSoViewController.h"
#import "AppDelegate.h"
#import "NfcViewController.h"
#import "MapAddressSaveViewController.h"
#import "UIView+Toast.h"
#import "DBManager.h"
#import "UITableView+Utility.h"
#import "CallkitController.h"

@interface MapSearchResultListController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UILabel *lbSearchResult;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbSearchQuery;

@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;


@end

@implementation MapSearchResultListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblView.tableHeaderView = _headerview;
    _tblView.estimatedRowHeight = 120;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    _lbSearchResult.text = [NSString stringWithFormat:@"총 %ld건의 검색결고가 있습니다.", _arrData.count];
    _lbCurrentAddress.text = _curPlaceInfo.jibun_address;
    _lbSearchQuery.text = _searchQuery;
    
    [self.tblView reloadData:^{
        [self.tblView layoutIfNeeded];
        [self.view layoutIfNeeded];
        [self.tblView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)onClickedButtonActions:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MapSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapSearchResultCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchResultCell" owner:self options:0].firstObject;
    }
    
    __block PlaceInfo *info = [_arrData objectAtIndex:indexPath.row];
    cell.type = MapSearchResultCellArroundSearch;
    [cell configurationData:info];
    
    [cell setOnTouchUpInSideAction:^(MapCellAction action, PlaceInfo *data) {
        self.selPlaceInfo = data;

        if (action == MapCellActionSave) {
            AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
            vc.viewType = ViewTypeAdd;
            vc.placeInfo = self.selPlaceInfo;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (action == MapCellActionNfc) {
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            vc.passPlaceInfo = self.selPlaceInfo;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (action == MapCellActionNavi) {
            NSString *url = [self getNaviUrlWithPalceInfo:self.selPlaceInfo];
            [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                if (success) {
                    [self saveHisotryWithPlaceInfo:self.selPlaceInfo type:4];
                }
                else {
                    [self.view makeToast:@"설정된 지도앱을 열수 없습니다."];
                }
            }];
        }
        else if (action == MapCellActionPhone && self.selPlaceInfo.phone_number != nil) {
            NSLog(@"%@", self.selPlaceInfo.phone_number);
            NSString *url = [NSString stringWithFormat:@"tel://%@", self.selPlaceInfo.phone_number];
            self.callType = @"1";
            if (self.callkitController == nil) {
                self.callkitController = [[CallkitController alloc] init];
                self.arrCallState = [NSMutableArray array];
            }

            [[AppDelegate instance] openSchemeUrl:url];
        }
        else if (action == MapCellActionShare) {
            
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MapSearchResultCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selPlaceInfo = cell.info;
    
    MapAddressSaveViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAddressSaveViewController"];
    vc.passPlaceInfo = self.selPlaceInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"TotalJoosoListViewCon %@", state);
    
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        NSDate *curDate = [NSDate date];
        if (self.selPlaceInfo.phone_number != nil) {
            
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
            
            [param setObject:self.selPlaceInfo.name forKey:@"name"];
            [param setObject:self.selPlaceInfo.phone_number  forKey:@"phoneNumber"];
            [param setObject:callState forKey:@"callState"];
            [param setObject:_callType forKey:@"callType"];
            [param setObject:[NSDate date] forKey:@"createDate"];
            [param setObject:[NSNumber numberWithDouble:takeCalling] forKey:@"takeCalling"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"callCnt"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"historyType"];
            [param setObject:[NSNumber numberWithDouble:self.selPlaceInfo.x] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:self.selPlaceInfo.y] forKey:@"geoLng"];
            if (self.selPlaceInfo.jibun_address != nil) {
                [param setObject:self.selPlaceInfo.jibun_address forKeyedSubscript:@"address"];
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
