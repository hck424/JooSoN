//
//  AroundSearchViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AroundSearchViewController.h"
#import "NaverMapView.h"
#import "GoogleMapView.h"
#import "KakaoMapView.h"
#import "CustomInfoView.h"
#import "DBManager.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "MapSearchResultListController.h"
#import "SceneDelegate.h"

@interface AroundSearchViewController () <LocationViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgBlock1;
@property (weak, nonatomic) IBOutlet UIView *bgBlock2;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (strong, nonatomic) IBOutletCollection(VerticalButton) NSArray *arrBtnItem;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;

@property (strong, nonatomic) NSMutableArray *arrSearchKey;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, strong) NaverMapView *naverMapView;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) KakaoMapView *kakaoMapView;
@property (nonatomic, strong) UIView *selMapView;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;


@end

@implementation AroundSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _bgBlock1.layer.cornerRadius = 8.0;
    _bgBlock1.layer.borderColor = RGB(216, 216, 216).CGColor;
    _bgBlock1.layer.borderWidth = 1.0f;
    
    _bgBlock2.layer.cornerRadius = 8.0;
    _bgBlock2.layer.borderColor = RGB(216, 216, 216).CGColor;
    _bgBlock2.layer.borderWidth = 1.0f;
    
    self.arrSearchResult = [NSMutableArray array];
    _tfSearch.inputAccessoryView = _accessoryView;
    
    self.arrSearchKey = [NSMutableArray arrayWithObjects:@"주유소", @"전기차 충전소", @"LPG", @"자동차 정비소", @"주차장", @"병원", @"약국", @"경찰서", @"음식점", @"카페", @"은행", @"관광안내소", @"숙박", @"지하철", nil];
    
    self.arrBtnItem = [_arrBtnItem sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    
    for (UIButton *btn in _arrBtnItem) {
        [btn addTarget:self action:@selector(onClickedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    _lbCurrentLoc.text = @"";
    [self addMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)addMapView {
    NSString *mapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    
    if (_naverMapView) {
        [_naverMapView removeFromSuperview];
    }
    if (_googleMapView) {
        [_googleMapView removeFromSuperview];
    }
    if (_kakaoMapView) {
        [_kakaoMapView removeFromSuperview];
    }
    
    if ([mapId isEqualToString:MapIdNaver]) {
        [self addSubViewNaverMapView];
    }
    else if ([mapId isEqualToString:MapIdKakao]) {
        [self addSubViewKakaoMapView];
    }
    else if ([mapId isEqualToString:MapIdGoogle]) {
        [self addSubViewGoogleMapView];
    }

}
- (IBAction)onClickedButtonAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
       UIButton *selBtn = sender;
        if (selBtn.tag >= 100 && selBtn.tag <= 113) {
            NSInteger idx = selBtn.tag - 100;
            NSString *searchKey = @"";
            
            if (idx < _arrSearchKey.count) {
                searchKey = [_arrSearchKey objectAtIndex:idx];
            }
            for (UIButton *btn in _arrBtnItem) {
                btn.selected = NO;
            }
            selBtn.selected = YES;
            
            if ([self.selMapView respondsToSelector:@selector(hideAllMarker)]) {
                [self.selMapView performSelector:@selector(hideAllMarker)];
            }
            
            NSString *searQuery = [NSString stringWithFormat:@"%@ %@", _curPlaceInfo.city, searchKey];
            [self requestNaverSearchQuery:searQuery isViewChange:NO];
            _tfSearch.text = searQuery;
        }
        else if (sender == _btnSearch) {
            if (_tfSearch.text.length == 0) {
                [self.view makeToast:@"검색어를 입력해 주세요" duration:0.5 position:CSToastPositionTop];
                return;
            }
            
            [self requestNaverSearchQuery:_tfSearch.text isViewChange:YES];
        }
    }
    else {if (sender == _btnKeyboardDown) {
        [self.view endEditing:YES];
    }
    }
}

- (void)refreshMapSearchResultView:(BOOL)isViewChange searQuery:(NSString *)searQuery {
    if (isViewChange == NO) {
        for (NSInteger i = 0; i < self.arrSearchResult.count; i++) {
            PlaceInfo *info = [self.arrSearchResult objectAtIndex:i];
            if ([self.selMapView respondsToSelector:@selector(setMarker:)]) {
                [self.selMapView performSelector:@selector(setMarker:) withObject:info];
            }
        }
        
        if ([self.selMapView respondsToSelector:@selector(selectedMarkerWithPlaceInfo:)]) {
            [self.selMapView performSelector:@selector(selectedMarkerWithPlaceInfo:) withObject:[_arrSearchResult firstObject]];
        }
    }
    else {
        MapSearchResultListController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapSearchResultListController"];
        vc.arrData = self.arrSearchResult;
        vc.searchQuery = searQuery;
        vc.curPlaceInfo = self.curPlaceInfo;
        [[SceneDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    }
}
- (void)requestNaverSearchQuery:(NSString *)searQuery isViewChange:(BOOL)isViewChange {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _curPlaceInfo.y;
    coordinate.longitude = _curPlaceInfo.x;
    
    __weak typeof(self) weakSelf = self;
    
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        [[DBManager instance] nmapSearchPlace:searQuery coordinate:coordinate orderBy:nil success:^(NSDictionary *dataDic) {
            if ([[dataDic objectForKey:@"places"] count] > 0) {
                [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
                [weakSelf refreshMapSearchResultView:isViewChange searQuery:searQuery];
            }
            else {
                [self.view makeToast:@"검색 결과 없습니다." duration:1.0 position:CSToastPositionTop];
            }
        } fail:^(NSError *error) {
            
        }];
    } else {
        [[DBManager instance] googleMapSearchPlace:searQuery coordinate:coordinate circle:2000 success:^(NSDictionary *dataDic) {
            if ([[dataDic objectForKey:@"places"] count] > 0) {
                [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
                [weakSelf refreshMapSearchResultView:isViewChange searQuery:searQuery];
            }
            else {
                if ([[dataDic objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]) {
                    [self.view makeToast:@"검색 최소시간 이내에 요청하셨습니다. 잠시 후 다시 시도해 주세요." duration:1.0 position:CSToastPositionTop];
                }
                else {
                    [self.view makeToast:@"검색 결과 없습니다." duration:1.0 position:CSToastPositionTop];
                }
            }
        } fail:^(NSError *error) {
            
        }];
    }
}

#pragma mark - add mapview
- (void)addSubViewKakaoMapView {
    self.kakaoMapView = [[NSBundle mainBundle] loadNibNamed:@"KakaoMapView" owner:self options:nil].firstObject;
    _kakaoMapView.frame = _mapContainer.bounds;
    _kakaoMapView.delegate = self;
    _kakaoMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_kakaoMapView];
    [_kakaoMapView startCurrentLocationUpdatingLocation];
    self.selMapView = _kakaoMapView;
}
- (void)addSubViewGoogleMapView {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapContainer.bounds;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    
    [_googleMapView startCurrentLocationUpdatingLocation];
    self.selMapView = _googleMapView;
}
- (void)addSubViewNaverMapView {
    self.naverMapView = [[NSBundle mainBundle] loadNibNamed:@"NaverMapView" owner:self options:nil].firstObject;
    _naverMapView.frame = _mapContainer.bounds;
    _naverMapView.delegate = self;
    _naverMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_naverMapView];
    [_naverMapView startCurrentLocationUpdatingLocation];
    
    self.selMapView = _naverMapView;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] == 0) {
        [self.view makeToast:@"검색어를 입력해주세요." duration:1.0 position:CSToastPositionTop];
    }
    else {
        [_btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return YES;
}

#pragma mark - LocationViewDelegate
- (void)locationView:(id)locationView curPlaceInfo:(PlaceInfo *)curPlaceInfo {
    self.curPlaceInfo = curPlaceInfo;
    if ([_curPlaceInfo.jibun_address length] > 0) {
        _lbCurrentLoc.text = _curPlaceInfo.jibun_address;
    }
    [locationView stopCurrentLocationUpdatingLocation];
    
    self.selPlaceInfo = _curPlaceInfo;
    if ([self.selMapView respondsToSelector:@selector(setCurrentMarker:)]) {
        [self.selMapView performSelector:@selector(setCurrentMarker:) withObject:[NSNumber numberWithBool:YES]];
    }
}

@end
