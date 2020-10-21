//
//  MapSearchViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/11.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchViewController.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "DBManager.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"
#import "MapSearchCell.h"
#import "BannerFlowLayout.h"
#import "UIView+Toast.h"

@interface MapSearchViewController () <LocationViewDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BannerFlowLayoutDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnCurLocation;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) UIView *selMapView;

//@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
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
    
    [self addSubViewGoogleMapView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MapSearchCell" bundle:nil] forCellWithReuseIdentifier:@"MapSearchCell"];
    
    BannerFlowLayout *layout = [[BannerFlowLayout alloc] init];
    self.collectionView.collectionViewLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
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
        [_googleMapView startCurrentLocationUpdatingLocation];
    }
    else if (sender == _btnKeyboardDown) {
        [self.view endEditing:YES];
    }
    else if (sender == _btnMic) {
        [SpeechAlertView showWithTitle:@"JooSoN" completion:^(NSString * _Nonnull result) {
            if (result.length > 0) {
                self.tfSearch.text = result;
                [self.btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }];
    }
    else if (sender == _btnSave) {
        if ([self.delegate respondsToSelector:@selector(mapSearchVCSelectedPlace:)]) {
            [self.delegate mapSearchVCSelectedPlace:self.selPlaceInfo];
        }
        [self.navigationController popViewControllerAnimated:NO];
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
    coordinate.latitude = _passPlaceInfo.x;
    coordinate.longitude = _passPlaceInfo.y;
    NSString *searQuery = _tfSearch.text;
    
    [_googleMapView hideAllMarker];
    [_googleMapView setCurrentMarker];
    
    [DBManager.instance googleMapSearchPlace:searQuery type:@"D" coordinate:coordinate circle:2000 success:^(NSDictionary *dataDic) {
        if ([[dataDic objectForKey:@"places"] count] > 0) {
            self.collectionView.hidden = NO;
            [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
            for (PlaceInfo *info in self.arrSearchResult) {
                [self.googleMapView setMarker:info draggable:NO];
            }
            [self.googleMapView moveMarker:self.arrSearchResult.firstObject zoom:17];
            
            [self.collectionView reloadData];
        }
        else {
            self.collectionView.hidden = YES;
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

#pragma mark - UIcollectionviewdelegate, datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  _arrSearchResult.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MapSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapSearchCell" forIndexPath:indexPath];
    PlaceInfo *info = [_arrSearchResult objectAtIndex:indexPath.row];
    [cell configurationData:info];
    [cell setOnTouchUpInSideAction:^(MapCellAction action, PlaceInfo * _Nonnull data) {
        self.selPlaceInfo = data;
        if (action == MapCellActionSave) {
            if ([self.delegate respondsToSelector:@selector(mapSearchVCSelectedPlace:)]) {
                [self.delegate mapSearchVCSelectedPlace:self.selPlaceInfo];
            }
            [self.navigationController popViewControllerAnimated:NO];
        }
        else if (action == MapCellActionNfc) {
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            vc.passPlaceInfo = self.selPlaceInfo;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (action == MapCellActionNavi) {
            NSString *url = [self getNaviUrlWithPalceInfo:info];
            if (url.length > 0) {
                [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                    if (success) {
                        [self saveHisotryWithPlaceInfo:self.selPlaceInfo type:4];
                    }
                    else {
                        [self.view makeToast:@"지도가 설치되어 있지 않습니다."];
                    }
                }];
            }
        }
    }];
    return  cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellSize = collectionView.bounds.size;
    cellSize.width -= 8* collectionView.contentInset.left;
    cellSize.height = collectionView.frame.size.height;
    return cellSize;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selPlaceInfo = [_arrSearchResult objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(mapSearchVCSelectedPlace:)]) {
        [self.delegate mapSearchVCSelectedPlace:self.selPlaceInfo];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)bannerFlowLayout:(CGPoint)curPoint indexPath:(NSIndexPath *)indexPath {

}

#pragma mark - LocationViewDelegate
- (void)locationView:(id)locationView curPlaceInfo:(PlaceInfo *)curPlaceInfo {
    self.curPlaceInfo = curPlaceInfo;
    if ([_curPlaceInfo.jibun_address length] > 0) {
        _lbCurrentLoc.text = _curPlaceInfo.jibun_address;
    }
    [locationView stopCurrentLocationUpdatingLocation];
    
    self.selPlaceInfo = _curPlaceInfo;
    [self.googleMapView setCurrentMarker];
    [self.googleMapView moveMarker:self.curPlaceInfo zoom:15];
    [self.googleMapView setMarker:self.curPlaceInfo draggable:YES];
}



@end
