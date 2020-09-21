//
//  DestinationViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "DestinationViewController.h"
#import "DBManager.h"
#import "PlaceInfo.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "InstantPanGestureRecognizer.h"
#import "AddJooSoViewController.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"
#import "MapSearchCell.h"
#import "Define.h"
#import "BannerFlowLayout.h"

typedef enum : NSUInteger {
    Closed,
    Opened
} State;


@interface DestinationViewController () <UITextFieldDelegate,  LocationViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, BannerFlowLayoutDelegate, UICollectionViewDelegateFlowLayout, GoogleMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIView *currentLocView;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;

@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrentLoc;


@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) GoogleMapView *googleMapView;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, assign) CGFloat maxScrollHeight;
@property (nonatomic, assign) CGFloat minScrollHeight;
@property (nonatomic, strong) NSMutableArray *runningAnimators;
@property (nonatomic, assign) State currentState;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, strong) UIViewPropertyAnimator *transitionAnimator;
@property (nonatomic, assign) BOOL aniLock;

@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@property (nonatomic, strong) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
static NSString *cellIdentity = @"MapSearchCell";
@implementation DestinationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.runningAnimators = [NSMutableArray array];
    self.arrSearchResult = [NSMutableArray array];
    
    _tfSearch.inputAccessoryView = _accessoryView;
    
    _animationProgress = 0;
    _minScrollHeight = 120;
    _maxScrollHeight = 500;
    _currentState = Closed;
    _tfSearch.inputAccessoryView = _accessoryView;
    
//    InstantPanGestureRecognizer *pan = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesteurHandler:)];
//    pan.delegate = self;
    
    _tfSearch.text = @"맛집";
    
    _lbCurrentLoc.text = @"";
    [self addSubViewGoogleMapView];

    [self.collectionView registerNib:[UINib nibWithNibName:cellIdentity bundle:nil] forCellWithReuseIdentifier:cellIdentity];
    
    BannerFlowLayout *flowLayout = [[BannerFlowLayout alloc] init];
    flowLayout.delegate = self;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, BannerCellSpace, 0, BannerCellSpace);
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _resultView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view endEditing:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotiSelectPlaceInfo object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiSelectPlaceInfo object:nil];
}

- (void)reloadData {
    [_googleMapView hideAllMarker];
    [_googleMapView startCurrentLocationUpdatingLocation];
}

- (void)addSubViewGoogleMapView {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapContainer.bounds;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    [_googleMapView startCurrentLocationUpdatingLocation];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
}

- (void)showMapSearchResultListView:(NSString *)searQuery {
    
//    [_scrollView layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _curPlaceInfo.y;
    coordinate.longitude = _curPlaceInfo.x;
    
    [[DBManager instance] googleMapSearchPlace:searQuery coordinate:coordinate circle:2000 success:^(NSDictionary *dataDic) {
        if ([[dataDic objectForKey:@"places"] count] > 0) {
//            self.scrollView.hidden = NO;
            [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
            [weakSelf makeSearchResultView];
        }
        else {
//            self.scrollView.hidden = YES;
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

- (void)makeSearchResultView {
    
    [_googleMapView hideAllMarker];
    [_googleMapView setCurrentMarker];
    
//    for (UIView *subView in [self.svCellView subviews]) {
//        [subView removeFromSuperview];
//    }
    
    for (NSInteger i = 0; i < self.arrSearchResult.count; i++) {
        PlaceInfo *info = [self.arrSearchResult objectAtIndex:i];
        [_googleMapView setMarker:info icon:[UIImage imageNamed:@"icon_location_now"]];
    }
    [self.view layoutIfNeeded];
    
    _resultView.hidden = NO;
    
    [_collectionView reloadData];
    
//        MapSearchView *cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchView" owner:self options:nil].firstObject;
//        [_svCellView addArrangedSubview:cell];
//        [cell configurationData:info];
        
        
        

//    }
    [self.view setNeedsLayout];
//    CGSize fitSize = [_svContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    CGFloat height = fitSize.height;
//    _maxScrollHeight = height - 10;
//    if (height > _mapContainer.frame.size.height) {
//        _maxScrollHeight = _mapContainer.frame.size.height -10;
//    }
//    _heighScrollView.constant = _minScrollHeight;
}

#pragma mark - textField did changed
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {

}

#pragma mark - UIButton Actions
- (IBAction)onClickedButtonActions:(id)sender {
    [self.view endEditing:YES];
    if (sender == _btnSearch) {
        if (_tfSearch.text.length > 0) {
            [self showMapSearchResultListView:_tfSearch.text];
        }
        else {
            [self.view makeToast:@"검색어를 입력해주세요." duration:1.0 position:CSToastPositionTop];
        }
    }
    else if (sender == _btnSave) {
        AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
        vc.viewType = ViewTypeAdd;
        vc.placeInfo = _selPlaceInfo;
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    }
    else if (sender == _btnKeyboardDown) {
        [_tfSearch resignFirstResponder];
    }
    else if (sender == _btnCurrentLoc) {
        [_googleMapView stopCurrentLocationUpdatingLocation];
    }
}

#pragma mark - UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.view makeToast:@"검색어를 입력해 주세요." duration:1.0 position:CSToastPositionTop];
    }
    else {
        [self.btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)notificationHandler:(NSNotification *)notification {
    if ([notification.name isEqualToString:NotiNameHitTestView]) {
        [self.view endEditing:YES];
    }
    else if ([notification.name isEqualToString:NotiSelectPlaceInfo]) {
        self.selPlaceInfo = ((PlaceInfo *)notification.object);
        NSInteger index = 0;
        for (NSInteger i = 0; i < _arrSearchResult.count; i++) {
            PlaceInfo *info = [_arrSearchResult objectAtIndex:i];
            if ([info isEqual:_selPlaceInfo]) {
                index = i;
                break;
            }
        }
//        CGFloat contentW = self.collectionView.bounds.size.width - BannerCellSpace*self.collectionView.contentInset.left;
//        CGFloat offsetX = (index * contentW) + (index)*BannerCellSpace - BannerCellSpace;
//        [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
//
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (State)opposite:(State)state {
    if (state == Opened) {
        return Closed;
    }
    else {
        return Opened;
    }
}

#pragma mark -- UIGestureReconizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
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
    [self.googleMapView setCurrentMarker];
    
    [self.googleMapView moveMarker:self.curPlaceInfo zoom:17];
}
- (void)showNfcVC {
    
    NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
    vc.passPlaceInfo = self.selPlaceInfo;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
}

- (void)showNavi {
    NSString *url = nil;
    if ([AppDelegate.instance.selMapId isEqualToString:MapIdNaver]) {
        url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selPlaceInfo.y, self.selPlaceInfo.x, self.selPlaceInfo.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    }
    else if ([AppDelegate.instance.selMapId isEqualToString:MapIdGoogle]) {
        url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", self.selPlaceInfo.jibun_address, self.selPlaceInfo.y, self.selPlaceInfo.x];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    }
    
    if (url.length > 0) {
        [[AppDelegate instance] openSchemeUrl:url];
    }
}
- (void)showSaveVC {
    AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
    vc.viewType = ViewTypeAdd;
    vc.placeInfo = self.selPlaceInfo;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrSearchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MapSearchCell *cell = (MapSearchCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MapSearchCell" forIndexPath:indexPath];
    PlaceInfo *info = [_arrSearchResult objectAtIndex:indexPath.row];
    [cell configurationData:info];
    
    //FIXME:: cellTouch action
    [cell setOnTouchUpInSideAction:^(MapCellAction actionType, PlaceInfo *data) {
        self.selPlaceInfo = data;
        if (actionType == MapCellActionSave) {
            [self showSaveVC];
        }
        else if (actionType == MapCellActionNfc) {
            [self showNfcVC];
        }
        else if (actionType == MapCellActionNavi) {
            [self showNavi];
        }
        else if (actionType == MapCellActionDefault) {
            self.aniLock = NO;
//            [weakSelf startAnimation];
            //                [self.googleMapView selectedMarkerWithPlaceInfo:self.selPlaceInfo];
        }
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellSize = collectionView.bounds.size;
    cellSize.width -= BannerCellSpace*collectionView.contentInset.left;
    cellSize.height = collectionView.bounds.size.height;
    return cellSize;
}

- (void)bannerFlowLayout:(CGPoint)curPoint indexPath:(NSIndexPath *)indexPath {
    NSLog(@"offset x: %lf, indexPath: %@", curPoint.x, indexPath);
    if (indexPath.row < _arrSearchResult.count) {
        self.selPlaceInfo = [_arrSearchResult objectAtIndex:indexPath.row];
        [_googleMapView selectedMarker:_selPlaceInfo];
        [_googleMapView moveMarker:_selPlaceInfo zoom:15];
    }
}
#pragma mark - GoogleMapViewDelegate
- (void)googleMapView:(id)googleMapView didClickedAction:(MapCellAction)action withPlaceInfo:(PlaceInfo *)placeInfo {
    if (placeInfo != nil) {
        self.selPlaceInfo = placeInfo;
        if (action == MapCellActionNfc) {
            [self showNfcVC];
        }
        else if (action == MapCellActionNavi) {
            [self showNavi];
        }
    }
}
@end
