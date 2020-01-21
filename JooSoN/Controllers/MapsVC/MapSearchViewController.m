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
#import "DBManager.h"
#import "MapSearchView.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"
#import "KakaoMapView.h"
#import "SceneDelegate.h"

@interface MapSearchViewController () <LocationViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
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
@property (nonatomic, strong) NaverMapView *naverMapView;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) KakaoMapView *kakaoMapView;
@property (nonatomic, strong) UIView *selMapView;

@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, assign) CGFloat widthMapSearchView;


@end

@implementation MapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tfSearch.delegate = self;
    self.arrSearchResult = [NSMutableArray array];
    self.arrMarkers = [NSMutableArray array];
    _lbCurrentLoc.text = @"";
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        [self addSubViewNaverMapView];
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        [self addSubViewGoogleMapView];
    }
    else if ([selMapId isEqualToString:MapIdKakao]) {
        [self addSubViewKakaoMapView];
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
    NSString *searQuery = _tfSearch.text;
    
    __weak typeof(self) weakSelf = self;
    NSString *selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    if ([selMapId isEqualToString:MapIdNaver]) {
        [[DBManager instance] nmapSearchPlace:searQuery coordinate:coordinate orderBy:NMAP_ORDERBY_WEIGHT success:^(NSDictionary *dataDic) {
            
            if ([[dataDic objectForKey:@"places"] count] > 0) {
                self.scrollView.hidden = NO;
                [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
                [weakSelf makeSearchResultView];
            }
            else {
                self.scrollView.hidden = YES;
                [self.view makeToast:@"검색 결과가 없습니다." duration:1.0 position:CSToastPositionTop];
            }
        } fail:^(NSError *error) {
            NSLog(@"error : %@", error);
        }];
    }
    else {
        [[DBManager instance] googleMapSearchPlace:searQuery coordinate:coordinate circle:2000 success:^(NSDictionary *dataDic) {
            if ([[dataDic objectForKey:@"places"] count] > 0) {
                self.scrollView.hidden = NO;
                [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
                [weakSelf makeSearchResultView];
            }
            else {
                self.scrollView.hidden = YES;
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
- (void)makeSearchResultView {
    self.widthMapSearchView = _scrollView.frame.size.width;
    
    if ([self.selMapView respondsToSelector:@selector(hideAllMarker)]) {
        [self.selMapView performSelector:@selector(hideAllMarker)];
    }
    
    for (UIView *subView in _svContent.subviews) {
        [subView removeFromSuperview];
    }
    
//    __weak typeof (self)weakSelf = self;
    for (PlaceInfo *info in _arrSearchResult) {
        MapSearchView *cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchView" owner:self options:0].firstObject;
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.widthAnchor constraintEqualToConstant:self.widthMapSearchView].active = YES;
        [cell configurationData:info];
        
        if ([self.selMapView respondsToSelector:@selector(setMarker:)]) {
            [self.selMapView performSelector:@selector(setMarker:) withObject:info];
        }
        
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
                [[SceneDelegate instance].rootNavigationController pushViewController:vc animated:NO];
            }
            else if (actionType == MapCellActionNavi) {
                NSString *url = nil;
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId] isEqualToString:MapIdNaver]) {
                    url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selPlaceInfo.y, self.selPlaceInfo.x, self.selPlaceInfo.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                }
                
                if (url.length > 0) {
                    [[SceneDelegate instance] openSchemeUrl:url];
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
    
    self.selMapView = _googleMapView;
    [_googleMapView startCurrentLocationUpdatingLocation];
}

- (void)addSubViewKakaoMapView {
    self.kakaoMapView = [[NSBundle mainBundle] loadNibNamed:@"KakaoMapView" owner:self options:nil].firstObject;
    _kakaoMapView.frame = _mapContainer.bounds;
    _kakaoMapView.delegate = self;
    _kakaoMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_kakaoMapView];
    
    self.selMapView = _kakaoMapView;
    [_kakaoMapView startCurrentLocationUpdatingLocation];
}

- (void)addSubViewNaverMapView {
    self.naverMapView = [[NSBundle mainBundle] loadNibNamed:@"NaverMapView" owner:self options:nil].firstObject;
    _naverMapView.frame = _mapContainer.bounds;
    _naverMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapContainer addSubview:_naverMapView];
    _naverMapView.delegate = self;

    self.selMapView = _naverMapView;
    [_naverMapView startCurrentLocationUpdatingLocation];
    
    if (_searchAddress.length > 0) {
        _tfSearch.text = _searchAddress;
    } else if (_passPlaceInfo.x > 0 && _passPlaceInfo.y > 0) {
        _tfSearch.text = _passPlaceInfo.jibun_address;
    }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger curPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    PlaceInfo *info = [_arrSearchResult objectAtIndex:curPage];
    self.selPlaceInfo = info;
    
    if ([self.selMapView respondsToSelector:@selector(selectedMarkerWithPlaceInfo:)]) {
        [self.selMapView performSelector:@selector(selectedMarkerWithPlaceInfo:) withObject:self.selPlaceInfo];
    }
}


@end
