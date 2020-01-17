//
//  DestinationViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "DestinationViewController.h"
#import "DBManager.h"
#import "NaverMapView.h"
#import "PlaceInfo.h"
#import "MapSearchView.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "InstantPanGestureRecognizer.h"
#import "CustomInfoView.h"
#import "AddJooSoViewController.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"


typedef enum : NSUInteger {
    Closed,
    Opened
} State;


@interface DestinationViewController () <UITextFieldDelegate,  NaverMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, NMFOverlayImageDataSource, GoogleMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIView *currentLocView;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *svContentView;

@property (weak, nonatomic) IBOutlet UIStackView *svCellView;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrentLoc;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heighScrollView;

@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) NaverMapView *naverMapView;
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

@property (nonatomic, strong) NMFInfoWindow *infoWindow;
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, strong) NMFMarker *curNaverMarker;
@property (nonatomic, strong) GMSMarker *curGoogleMarker;
@property (nonatomic, strong) NSString *selMapId;
@end

@implementation DestinationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.runningAnimators = [NSMutableArray array];
    self.arrSearchResult = [NSMutableArray array];
    
    _tfSearch.inputAccessoryView = _accessoryView;
    _scrollView.hidden = YES;
    _animationProgress = 0;
    _minScrollHeight = 120;
    _maxScrollHeight = 500;
    _currentState = Closed;
    _tfSearch.inputAccessoryView = _accessoryView;
    
    InstantPanGestureRecognizer *pan = [[InstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesteurHandler:)];
    pan.delegate = self;
    [_scrollView addGestureRecognizer:pan];
//    _tfSearch.text = @"명동";
    
    _scrollView.layer.cornerRadius = 20;
    _scrollView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner;
    self.selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    [self addMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:UIKeyboardWillHideNotification object:nil];
    self.selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    [self.view endEditing:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)addMapView {
    
    if (_naverMapView) {
        [_naverMapView removeFromSuperview];
    }
    if (_googleMapView) {
        [_googleMapView removeFromSuperview];
    }
    
    if ([_selMapId isEqualToString:MapIdNaver]) {
        [self addSubViewNaverMapView];
    }
    else if ([_selMapId isEqualToString:MapIdKakao]) {
        [self addSubViewKakaoMapView];
    }
    else if ([_selMapId isEqualToString:MapIdGoogle]) {
        [self addSubViewGoogleMapView];
    }
}

- (void)addSubViewNaverMapView {
    [self.view layoutIfNeeded];
    self.naverMapView = [[NSBundle mainBundle] loadNibNamed:@"NaverMapView" owner:self options:nil].firstObject;
    _naverMapView.frame = _mapContainer.bounds;
    _naverMapView.delegate = self;
    _naverMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.mapContainer addSubview:_naverMapView];
    [_naverMapView startCurrentLocationUpdatingLocation];
    _lbCurrentLoc.text = @"";
    
    self.infoWindow = NMFInfoWindow.infoWindow;
    _infoWindow.dataSource = self;
    _infoWindow.offsetX = -20;
    _infoWindow.offsetY = -3;
    _infoWindow.anchor = CGPointMake(0, 1);
    //        __weak typeof(_infoWindow) weakInfo = _infoWindow;
    //        _infoWindow.touchHandler = ^BOOL(NMFOverlay *__weak _Nonnull overay) {
    //            [weakInfo close];
    //            return YES;
    //        };
    _infoWindow.mapView = _naverMapView.map;
}
- (void)addSubViewGoogleMapView {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapContainer.bounds;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    
    [_googleMapView startCurrentLocationUpdatingLocation];

}
- (void)addSubViewKakaoMapView {
    
}

- (void)showMapSearchResultListView:(NSString *)searQuery {
    
    [_scrollView layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _curPlaceInfo.y;
    coordinate.longitude = _curPlaceInfo.x;
    
    
    if ([_selMapId isEqualToString:MapIdNaver]) {
        [[DBManager instance] nmapSearchPlace:searQuery coordinate:coordinate orderBy:NMAP_ORDERBY_WEIGHT success:^(NSDictionary *dataDic) {
            self.count = [[dataDic objectForKey:@"count"] integerValue];
            self.totalCount = [[dataDic objectForKey:@"totalCount"] integerValue];
            
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
                [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
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

- (void)hideAllMarker {
    if ([_selMapId isEqualToString:MapIdNaver]) {
        for (NMFMarker *maker in _arrMarkers) {
            maker.hidden = YES;
        }
        [_arrMarkers removeAllObjects];
    }
    else if ([_selMapId isEqualToString:MapIdGoogle]) {
        for (GMSMarker *marker in _arrMarkers) {
            marker.map = nil;
        }
        [_arrMarkers removeAllObjects];
        
        [_googleMapView.gmsMapView clear];
        [self setMark:_curPlaceInfo isCurLocation:YES selection:YES];
    }
}
- (void)makeSearchResultView {
    [self hideAllMarker];
    
    for (UIView *subView in [self.svCellView subviews]) {
        [subView removeFromSuperview];
    }
    __weak typeof (self) weakSelf = self;
    for (NSInteger i = 0; i < self.arrSearchResult.count; i++) {
        PlaceInfo *info = [self.arrSearchResult objectAtIndex:i];
        MapSearchView *cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchView" owner:self options:nil].firstObject;
        [_svCellView addArrangedSubview:cell];
        [cell configurationData:info];
        
        [weakSelf setMark:info isCurLocation:NO selection:NO];
        
        //FIXME:: cellTouch action
        [cell setOnTouchUpInSideAction:^(MapCellAction actionType, PlaceInfo *data) {
            self.selPlaceInfo = data;
            if (actionType == MapCellActionSave) {
                AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
                vc.viewType = ViewTypeAdd;
                vc.placeInfo = self.selPlaceInfo;
                [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
            }
            else if (actionType == MapCellActionNfc) {
                NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
                vc.passPlaceInfo = self.selPlaceInfo;
                [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
            }
            else if (actionType == MapCellActionNavi) {
                NSString *url = nil;
                if ([self.selMapId isEqualToString:MapIdNaver]) {
                  url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selPlaceInfo.y, self.selPlaceInfo.x, self.selPlaceInfo.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                }
                else if ([self.selMapId isEqualToString:MapIdGoogle]) {
                    url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", self.selPlaceInfo.jibun_address, self.selPlaceInfo.y, self.selPlaceInfo.x];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                }
                
                if (url.length > 0) {
                    [[AppDelegate instance] openSchemeUrl:url];
                }
            }
            else if (actionType == MapCellActionDefault) {
                self.aniLock = NO;
                [weakSelf startAnimation];
                
                if ([self.selMapId isEqualToString:MapIdNaver]) {
                    NMFMarker *selMarker = nil;
                    for (NMFMarker *marker in self.arrMarkers) {
                        [weakSelf selectedMark:marker selected:NO];
                        if ([((PlaceInfo *)[marker.userInfo objectForKey:@"placeInfo"]).sessionId isEqualToString:self.selPlaceInfo.sessionId]) {
                            selMarker = marker;
                        }
                    }
                    [weakSelf selectedMark:selMarker selected:YES];
                }
                else if ([self.selMapId isEqualToString:MapIdGoogle]) {
                    GMSMarker *selMarker = nil;
                    for (GMSMarker *marker in self.arrMarkers) {
                        [weakSelf selectedMark:marker selected:NO];
                        if ([[marker.userData objectForKey:@"placeInfo"] isEqual:self.selPlaceInfo]) {
                            selMarker = marker;
                        }
                    }
                    [weakSelf selectedMark:selMarker selected:YES];
                }
            }
        }];
    }
    [self.view setNeedsLayout];
    CGSize fitSize = [_svContentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat height = fitSize.height;
    _maxScrollHeight = height - 10;
    if (height > _mapContainer.frame.size.height) {
        _maxScrollHeight = _mapContainer.frame.size.height -10;
    }
    _heighScrollView.constant = _minScrollHeight;
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
        if ([_selMapId isEqualToString:MapIdNaver]) {
            if (self.curNaverMarker == nil) {
                self.curNaverMarker.hidden = YES;
            }
            
            [_naverMapView startCurrentLocationUpdatingLocation];
        }
        else if ([_selMapId isEqualToString:MapIdGoogle]) {
            [_googleMapView stopCurrentLocationUpdatingLocation];
        }
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
    else if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
//        CGFloat heightKeyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//        NSUInteger curvel = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] floatValue];
//
//
//        [self.view setNeedsUpdateConstraints];
//        [self.view setNeedsLayout];
//
//        [UIView animateWithDuration:duration delay:0.0 options:curvel animations:^{
//            [self.view layoutIfNeeded];
//        } completion:nil];
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
//        CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//
//        [UIView animateWithDuration:duration animations:^{
//            [self.view setNeedsLayout];
//        }];
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

#pragma mark - animation
- (void)anmimateTransitionIfNeeded:(State)state duration:(CGFloat)duration {
    
    State newState = [self opposite:state];
    __weak typeof (self) weakSelf = self;
    self.transitionAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:duration curve:UIViewAnimationCurveEaseIn animations:^{
        if (newState == Opened) {
            self.heighScrollView.constant = self.maxScrollHeight;
        }
        else {
            self.heighScrollView.constant = self.minScrollHeight;
        }
        self.scrollView.scrollEnabled = NO;
        [self.view layoutIfNeeded];
    }];
    
    [_transitionAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionStart) {
            weakSelf.currentState = [weakSelf opposite:newState];
        }
        else if (finalPosition == UIViewAnimatingPositionEnd) {
            weakSelf.currentState = newState;
        }
        
        if (self.currentState == Opened) {
            weakSelf.heighScrollView.constant = weakSelf.maxScrollHeight;
        }
        else if (self.currentState == Closed) {
            weakSelf.heighScrollView.constant = weakSelf.minScrollHeight;
        }
        weakSelf.scrollView.scrollEnabled = YES;
    }];
    
    [_transitionAnimator startAnimation];
    
}

- (void)startAnimation {
    [self anmimateTransitionIfNeeded:_currentState duration:0.3];
    [_transitionAnimator pausesOnCompletion];
}

- (void)panGesteurHandler:(UIPanGestureRecognizer *)panGesture {
    CGFloat vy = [_scrollView.panGestureRecognizer translationInView:_scrollView.superview].y;
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        _animationProgress = _transitionAnimator.fractionComplete;
        if (_aniLock == NO) {
            [self startAnimation];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [panGesture translationInView:_scrollView];
        CGFloat fraction = -translate.y / _minScrollHeight;
        if (_currentState == Opened) {
            fraction *= -1;
        }
        _transitionAnimator.fractionComplete = fraction + _animationProgress;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat yVelocity = [panGesture translationInView:_scrollView].y;
        BOOL shouldClose = yVelocity > 0;
        
        if (yVelocity == 0) {
            [_transitionAnimator continueAnimationWithTimingParameters:nil durationFactor:0];
            return;
        }
        
        if (_currentState == Opened) {
            if (shouldClose == NO && [_transitionAnimator isReversed] == NO) {
                [_transitionAnimator setReversed:!_transitionAnimator.isReversed];
            }
            if (shouldClose && _transitionAnimator.isReversed) {
                [_transitionAnimator setReversed:!_transitionAnimator.isReversed];
            }
        }
        else if (_currentState == Closed) {
            if (shouldClose && !_transitionAnimator.isReversed) {
                [_transitionAnimator setReversed:!_transitionAnimator.isReversed];
            }
            if (shouldClose == NO && _transitionAnimator.isReversed) {
                [_transitionAnimator setReversed:!_transitionAnimator.isReversed];
            }
        }
        [_transitionAnimator continueAnimationWithTimingParameters:nil durationFactor:0];
        
        NSLog(@"=== end %1f, %lf, %lf, %lf, open: %@", _scrollView.contentOffset.y, _scrollView.contentSize.height, _heighScrollView.constant, _scrollView.frame.size.height, _currentState == Opened? @"Y" : @"N");
        
        NSLog(@"=== vy : %lf", [_scrollView.panGestureRecognizer translationInView:_scrollView.superview].y);
        
        if (_scrollView.contentOffset.y + _heighScrollView.constant <= _scrollView.contentSize.height && yVelocity < 0) {
            _aniLock = YES;
        }
        else if (_scrollView.contentOffset.y < 0 && vy > 0 && _currentState == Opened) {
            _aniLock = NO;
            [self startAnimation];
        }
    }
}

#pragma mark -- UIGestureReconizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
            
            if ([[_arrSearchResult firstObject] isEqual:placeInfo]) {
                GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:14];
                [_googleMapView.gmsMapView animateWithCameraUpdate:move];
            }
        }
    }
}

- (void)selectedMark:(id)marker selected:(BOOL)selected {
    UIImage  *img = selected? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
    if ([_selMapId isEqualToString:MapIdNaver]) {
        NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
        NMFMarker *mk = marker;
        mk.iconImage = overlayImg;
        PlaceInfo *placeInfo = [mk.userInfo objectForKey:@"placeInfo"];
        if (selected) {
            [_infoWindow openWithMarker:marker];
            mk.infoWindow.hidden = NO;
            self.selPlaceInfo = placeInfo;
            NMGLatLng *latLng = NMGLatLngMake(placeInfo.y, placeInfo.x);
            [_naverMapView.map moveCamera:[NMFCameraUpdate cameraUpdateWithScrollTo:latLng] completion:nil];
        }
        else {
            mk.infoWindow.hidden = YES;
        }
        mk.isForceShowIcon = YES;
    }
    else {
        GMSMarker *mk = marker;
        mk.icon = img;
        PlaceInfo *placeInfo = [mk.userData objectForKey:@"placeInfo"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = placeInfo.y;
        coordinate.longitude = placeInfo.x;
        
        if (selected) {
            self.selPlaceInfo = placeInfo;
            GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:14];
            [_googleMapView.gmsMapView animateWithCameraUpdate:move];
            [_googleMapView.gmsMapView setSelectedMarker:marker];
        }
        
    }
}
#pragma mark - NaverMapViewDelegate
- (void)naverMapView:(id)naverMapView curPlaceInfo:(nonnull PlaceInfo *)curPlaceInfo {
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
