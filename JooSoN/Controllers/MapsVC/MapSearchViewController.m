//
//  MapSearchViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/11.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchViewController.h"
#import "NaverMapView.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "CustomInfoView.h"
#import "DBManager.h"
#import "MapSearchView.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"

@interface MapSearchViewController () <NMFOverlayImageDataSource, NaverMapViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, GoogleMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIStackView *svContent;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnCurLocation;

@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, strong) NMFMarker *curNaverMarker;
@property (nonatomic, strong) GMSMarker *curGoogleMarker;
@property (nonatomic, strong) NaverMapView *naverMapView;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, assign) CGFloat widthMapSearchView;
@property (nonatomic, strong) NMFInfoWindow *infoWindow;
@property (nonatomic, assign) CGFloat spaceX;

@end

@implementation MapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tfSearch.delegate = self;
    
    self.arrMarkers = [NSMutableArray array];
    _lbCurrentLoc.text = @"";
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        [self addSubViewNaverMapView];
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        [self addSubViewGoogleMapView];
    }
}

- (IBAction)onClickedButtonActins:(id)sender {
    [self.view endEditing:YES];
    
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _btnSearch) {
        if (_tfSearch.text.length == 0) {
            [self.view makeToast:@"검색어를 입력해주세요." duration:0.5 position:CSToastPositionTop];
            return;
        }
        
        [self requestMapSearchQuery];
    }
    else if (sender == _btnCurLocation) {
        [_naverMapView startCurrentLocationUpdatingLocation];
    }
    else if (sender == _btnKeyboardDown) {
        
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.view makeToast:@"검색어를 입력해주세요." duration:1.0 position:CSToastPositionTop];
    }
    else {
        [_btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return YES;
}

- (void)requestMapSearchQuery {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _passPlaceInfo.y;
    coordinate.longitude = _passPlaceInfo.x;
    
    __weak typeof(self) weakSelf = self;
    [[DBManager instance] nmapSearchPlace:_tfSearch.text coordinate:coordinate orderBy:nil success:^(NSDictionary *dataDic) {
        
        if ([[dataDic objectForKey:@"places"] count] > 0) {
            if (self.arrSearchResult == nil) {
                self.arrSearchResult = [NSMutableArray array];
            }
            self.scrollView.hidden = NO;
            [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
            [weakSelf makeSearchResultView];
        }
        else {
            self.scrollView.hidden = YES;
            [self.view makeToast:@"검색 결과가 없습니다." duration:1.0 position:CSToastPositionTop];
        }

    } fail:^(NSError *error) {
        NSLog(@"%@", error);
    }];

}
- (void)makeSearchResultView {
    self.widthMapSearchView = _scrollView.frame.size.width;
    
    for (UIView *subView in _svContent.subviews) {
        [subView removeFromSuperview];
    }
    
    for (NMFMarker *marker in _arrMarkers) {
        marker.hidden = YES;
    }
    [_arrMarkers removeAllObjects];
    
//    __weak typeof (self)weakSelf = self;
    for (PlaceInfo *info in _arrSearchResult) {
        MapSearchView *cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchView" owner:self options:0].firstObject;
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.widthAnchor constraintEqualToConstant:self.widthMapSearchView].active = YES;
        [cell configurationData:info];
        
        
        [cell setOnTouchUpInSideAction:^(MapCellAction actionType, PlaceInfo * _Nonnull data) {
            self.selPlaceInfo = data;
            if (actionType == MapCellActionSave
                || actionType == MapCellActionDefault) {
                if ([self.delegate respondsToSelector:@selector(mapSearchVCSelectedPlace:)]) {
                    [self.delegate mapSearchVCSelectedPlace:self.selPlaceInfo];
                }
                [self.navigationController popViewControllerAnimated:NO];
            }
            else if (actionType == MapCellActionNfc) {
                NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
                vc.passPlaceInfo = self.selPlaceInfo;
                [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
            }
            else if (actionType == MapCellActionNavi) {
                NSString *url = nil;
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId] isEqualToString:MapIdNaver]) {
                    url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selPlaceInfo.y, self.selPlaceInfo.x, self.selPlaceInfo.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                }
                
                if (url.length > 0) {
                    [[AppDelegate instance] openSchemeUrl:url];
                }
            }
        }];
        [_svContent addArrangedSubview:cell];
    }
    
}
#pragma mark - Map AddSubview
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
    _naverMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapContainer addSubview:_naverMapView];
    _naverMapView.delegate = self;
    self.infoWindow = NMFInfoWindow.infoWindow;
    self.infoWindow.dataSource = self;
    _infoWindow.offsetX = -20;
    _infoWindow.offsetY = -3;
    _infoWindow.anchor = CGPointMake(0, 1);
    _infoWindow.mapView = _naverMapView.map;
    [_naverMapView startCurrentLocationUpdatingLocation];
    
    if (_searchAddress.length > 0) {
        _tfSearch.text = _searchAddress;
    }
    else if (_passPlaceInfo.x > 0 && _passPlaceInfo.y > 0) {
        [self setMark:_passPlaceInfo isCurLocation:NO selection:YES];
        _tfSearch.text = _passPlaceInfo.jibun_address;
    }
}

- (void)setMark:(PlaceInfo *)placeInfo isCurLocation:(BOOL)isCurLocation selection:(BOOL)selection {
    
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        NMGLatLng *latLng = NMGLatLngMake(placeInfo.y, placeInfo.x);
        __block NMFMarker *marker = [NMFMarker markerWithPosition:latLng];
        UIImage *img = nil;
        if (isCurLocation) {
            img = selection? [UIImage imageNamed:@"icon_location_my"] : [UIImage imageNamed:@"icon_location_now_s"];
        }
        else {
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
        
        if (title.length == 0) {
            return;
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
        
        if (selection) {
            _infoWindow.hidden = NO;
        }
        else {
            _infoWindow.hidden = YES;
        }
        
        marker.mapView = _naverMapView.map;
        
        if (isCurLocation == NO) {
            if (_arrMarkers == nil) {
                self.arrMarkers = [NSMutableArray array];
            }
            [_arrMarkers addObject:marker];
        }
        else {
            self.curNaverMarker = marker;
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
    
    UIImage  *img = selected? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        NMFMarker *mk = marker;
        NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
        mk.iconImage = overlayImg;
        if (selected) {
            [NMFInfoWindow.infoWindow openWithMarker:mk];
            mk.infoWindow.hidden = NO;
            self.selPlaceInfo = [mk.userInfo objectForKey:@"placeInfo"];
        }
        else {
            mk.infoWindow.hidden = YES;
        }
        mk.isForceShowIcon = YES;
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        GMSMarker *mk = marker;
        mk.icon = img;
        if (selected) {
            self.selPlaceInfo = [mk.userData objectForKey:@"placeInfo"];
        }
    }
}

#pragma mark - NMFOverlayImageDataSource
- (UIView *)viewWithOverlay:(NMFOverlay *)overlay {
    CustomInfoView *infoView = [[NSBundle mainBundle] loadNibNamed:@"CustomInfoView" owner:nil options:0].firstObject;
    infoView.lbTitle.text = [self.infoWindow.marker.userInfo objectForKey:@"tag"];
    
    CGSize fitSize = [infoView.lbTitle sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.heightTitle.constant = fitSize.height;
    infoView.widthTitle.constant = fitSize.width;
    [infoView setNeedsLayout];
    [infoView layoutIfNeeded];
    
    return infoView;
}

#pragma mark - NaverMapViewDelegate
- (void)naverMapView:(id)naverMapView curPlaceInfo:(PlaceInfo *)curPlaceInfo {
    self.curPlaceInfo = curPlaceInfo;
    _lbCurrentLoc.text = _curPlaceInfo.jibun_address;
    [_naverMapView stopCurrentLocationUpdatingLocation];
    
    [self setMark:_curPlaceInfo isCurLocation:YES selection:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger curPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    PlaceInfo *info = [_arrSearchResult objectAtIndex:curPage];
    for (NMFMarker *marker in _arrMarkers) {
        [self selectedMark:marker selected:NO];
    }
    
    [self setMark:info isCurLocation:NO selection:YES];
    
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
