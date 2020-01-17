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

#import "CustomInfoView.h"
#import "DBManager.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "MapSearchResultListController.h"

@interface AroundSearchViewController () <NaverMapViewDelegate, NMFOverlayImageDataSource, UITextFieldDelegate, GoogleMapViewDelegate>
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
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, strong) NaverMapView *naverMapView;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) NMFInfoWindow *infoWindow;
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, strong) NMFMarker *curMarker;
@property (nonatomic, strong) GMSMarker *curGoogleMarker;
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
    
    self.arrMarkers = [NSMutableArray array];
    self.arrSearchResult = [NSMutableArray array];
    
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
- (IBAction)onClickedButtonAction:(UIButton *)sender {
    
    if (sender.tag >= 100 && sender.tag <= 113) {
        NSInteger idx = sender.tag - 100;
        NSString *searchKey = @"";
        
        if (idx < _arrSearchKey.count) {
            searchKey = [_arrSearchKey objectAtIndex:idx];
        }
        for (UIButton *btn in _arrBtnItem) {
            btn.selected = NO;
        }
        sender.selected = YES;
        
        [self hideAllMarker];
        
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
    else if (sender == _btnKeyboardDown) {
        [self.view endEditing:YES];
    }
}

- (void)hideAllMarker {
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    
    if ([selMapId isEqualToString:MapIdNaver]) {
        for (NMFMarker *marker in _arrMarkers) {
            marker.hidden = YES;
        }
        [_arrMarkers removeAllObjects];
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        for (GMSMarker *marker in _arrMarkers) {
            marker.map = nil;
        }
        [_arrMarkers removeAllObjects];
        [_googleMapView.gmsMapView clear];
        [self setMark:_curPlaceInfo isCurLocation:YES selection:YES];
    }
}
- (void)refreshMapSearchResultView:(BOOL)isViewChange searQuery:(NSString *)searQuery {
    if (isViewChange == NO) {
        for (NSInteger i = 0; i < self.arrSearchResult.count; i++) {
            PlaceInfo *info = [self.arrSearchResult objectAtIndex:i];
            [self setMark:info isCurLocation:NO selection:NO];
        }
        [self selectedMark:[self.arrMarkers firstObject] selected:YES];
    }
    else {
        MapSearchResultListController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapSearchResultListController"];
        vc.arrData = self.arrSearchResult;
        vc.searchQuery = searQuery;
        vc.curPlaceInfo = self.curPlaceInfo;
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
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
    } else if ([selMapId isEqualToString:MapIdGoogle]) {
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
    
}
- (void)addSubViewGoogleMapView {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapContainer.bounds;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    
    [_googleMapView startCurrentLocationUpdatingLocation];
    
}
- (void)addSubViewNaverMapView {
    self.naverMapView = [[NSBundle mainBundle] loadNibNamed:@"NaverMapView" owner:self options:nil].firstObject;
    _naverMapView.frame = _mapContainer.bounds;
    _naverMapView.delegate = self;
    _naverMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_naverMapView];
    [_naverMapView startCurrentLocationUpdatingLocation];
    
    
    self.infoWindow = NMFInfoWindow.infoWindow;
    _infoWindow.dataSource = self;
    _infoWindow.offsetX = -20;
    _infoWindow.offsetY = -3;
    _infoWindow.anchor = CGPointMake(0, 1);
    _infoWindow.mapView = _naverMapView.map;
    
    [_naverMapView startCurrentLocationUpdatingLocation];
}

- (void)setMark:(PlaceInfo *)placeInfo isCurLocation:(BOOL)isCurLocation selection:(BOOL)selection {
    
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        NMGLatLng *latLng = NMGLatLngMake(placeInfo.y, placeInfo.x);
        __block NMFMarker *marker = [NMFMarker markerWithPosition:latLng];
        UIImage *img = nil;
        if (isCurLocation) {
            img = selection? [UIImage imageNamed:@"icon_location_my"] : [UIImage imageNamed:@"icon_location_now_s"];
        } else {
            img = selection? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
        }
        
        NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
        marker.iconImage = overlayImg;
        
        marker.angle = 0;
        marker.iconPerspectiveEnabled = YES;
        marker.mapView = _naverMapView.map;
        [_naverMapView.map moveCamera:[NMFCameraUpdate cameraUpdateWithScrollTo:latLng] completion:nil];
        
        NSString *title = placeInfo.name;
        if (title == nil) {
            title = placeInfo.street;
        }
        
        marker.userInfo = @{@"tag" : title, @"placeInfo" : placeInfo};
        __weak typeof(self) wealSelf = self;
        __weak typeof(marker) weakMark = marker;
        
        [marker setTouchHandler:^BOOL(NMFOverlay *__weak _Nonnull overay) {
            if (isCurLocation == NO) {
                for (NMFMarker *nm in self.arrMarkers) {
                    [wealSelf selectedMark:nm selected:NO];
                }
                [wealSelf selectedMark:weakMark selected:YES];
            }
            
            [self.infoWindow openWithMarker:weakMark];
            self.infoWindow.hidden = NO;
            return YES;
        }];
        
        marker.mapView = _naverMapView.map;
        
        if (isCurLocation == NO) {
            if (_arrMarkers == nil) {
                self.arrMarkers = [NSMutableArray array];
            }
            [_arrMarkers addObject:marker];
        }
        else {
            self.curMarker = marker;
            self.selPlaceInfo = placeInfo;
        }
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = placeInfo.y;
        coordinate.longitude = placeInfo.x;
        if (isCurLocation) {
            self.curGoogleMarker = [[GMSMarker alloc] init];
            _curGoogleMarker.position = CLLocationCoordinate2DMake(_curPlaceInfo.y, _curPlaceInfo.x);
            _curGoogleMarker.title = placeInfo.name;
            _curGoogleMarker.snippet = placeInfo.jibun_address;
            _curGoogleMarker.map = _googleMapView.gmsMapView;
            
            UIImage *img = selection? [UIImage imageNamed:@"icon_location_my"] : [UIImage imageNamed:@"icon_location_now_s"];
            _curGoogleMarker.icon = img;
            
            GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:17];
            [_googleMapView.gmsMapView animateWithCameraUpdate:move];
        }
        else {
            UIImage *img = selection? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.icon = img;
            marker.position = coordinate;
            marker.title = placeInfo.name;
            marker.snippet = placeInfo.jibun_address;
            marker.map = _googleMapView.gmsMapView;
            
            marker.userData = @{@"tag" : placeInfo.name, @"placeInfo" : placeInfo};
            if (_arrMarkers == nil) {
                self.arrMarkers = [NSMutableArray array];
            }
            
            [_arrMarkers addObject:marker];
            
            GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:14];
            [_googleMapView.gmsMapView animateWithCameraUpdate:move];
        }
    }
}

- (void)selectedMark:(id)marker selected:(BOOL)selected {
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        
        UIImage  *img = selected? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
        NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
        NMFMarker *mk = (NMFMarker *)marker;
        NMFCameraUpdate *carmeraUpdate = [NMFCameraUpdate cameraUpdateWithScrollTo:mk.position];
        [_naverMapView.map moveCamera:carmeraUpdate completion:nil];
        
        mk.iconImage = overlayImg;
        if (selected) {
            [_infoWindow openWithMarker:marker];
            mk.infoWindow.hidden = NO;
            self.selPlaceInfo = [mk.userInfo objectForKey:@"placeInfo"];
        }
        else {
            mk.infoWindow.hidden = YES;
        }
        mk.isForceShowIcon = YES;
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
    }
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
#pragma mark - NaverMapViewDelegate
- (void)naverMapView:(id)naverMapView curPlaceInfo:(PlaceInfo *)curPlaceInfo {
    self.curPlaceInfo = curPlaceInfo;
    if ([_curPlaceInfo.jibun_address length] > 0) {
        _lbCurrentLoc.text = _curPlaceInfo.jibun_address;
    }
    [_naverMapView stopCurrentLocationUpdatingLocation];
    [self setMark:_curPlaceInfo isCurLocation:YES selection:YES];

}

#pragma mark - NMFOverlayImageDataSource
- (UIView *)viewWithOverlay:(NMFOverlay *)overlay {
    CustomInfoView *infoView = [[NSBundle mainBundle] loadNibNamed:@"CustomInfoView" owner:nil options:0].firstObject;
    infoView.lbTitle.text = [_infoWindow.marker.userInfo objectForKey:@"tag"];
    
    CGSize fitSize = [infoView.lbTitle sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.heightTitle.constant = fitSize.height;
    infoView.widthTitle.constant = fitSize.width;
    [infoView setNeedsLayout];
    [infoView layoutIfNeeded];
    return infoView;
}

#pragma mark - GoogleMapViewDelegate
- (void)googleMapView:(id)googleMapView curPlaceInfo:(PlaceInfo *)curPlaceInfo {
    self.curPlaceInfo = curPlaceInfo;
    if ([_curPlaceInfo.jibun_address length] > 0) {
        _lbCurrentLoc.text = _curPlaceInfo.jibun_address;
    }
    [_googleMapView stopCurrentLocationUpdatingLocation];
    [self setMark:_curPlaceInfo isCurLocation:YES selection:YES];
}

@end
