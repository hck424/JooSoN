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
#import "KakaoMapView.h"


typedef enum : NSUInteger {
    Closed,
    Opened
} State;


@interface DestinationViewController () <UITextFieldDelegate,  LocationViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

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
@property (nonatomic, strong) KakaoMapView *kakaoMapView;
@property (nonatomic, strong) UIView *selMapView;

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
    _lbCurrentLoc.text = @"";
    [self addMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    [self.view endEditing:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotiSelectPlaceInfo object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiSelectPlaceInfo object:nil];
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
    self.selMapView = _naverMapView;
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

- (void)addSubViewKakaoMapView {
    self.kakaoMapView = [[NSBundle mainBundle] loadNibNamed:@"KakaoMapView" owner:self options:nil].firstObject;
    _kakaoMapView.frame = _mapContainer.bounds;
    _kakaoMapView.delegate = self;
    _kakaoMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_kakaoMapView];
    [_kakaoMapView startCurrentLocationUpdatingLocation];
    self.selMapView = _kakaoMapView;
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
    
    if ([self.selMapView respondsToSelector:@selector(hideAllMarker)]) {
        [self.selMapView performSelector:@selector(hideAllMarker)];
    }
    
    for (UIView *subView in [self.svCellView subviews]) {
        [subView removeFromSuperview];
    }
    __weak typeof (self) weakSelf = self;
    for (NSInteger i = 0; i < self.arrSearchResult.count; i++) {
        PlaceInfo *info = [self.arrSearchResult objectAtIndex:i];
        MapSearchView *cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchView" owner:self options:nil].firstObject;
        [_svCellView addArrangedSubview:cell];
        [cell configurationData:info];
        
        if ([self.selMapView respondsToSelector:@selector(setMarker:)]) {
            [self.selMapView performSelector:@selector(setMarker:) withObject:info];
        }
        
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
                if ([self.selMapView respondsToSelector:@selector(selectedMarkerWithPlaceInfo:)]) {
                    [self.selMapView performSelector:@selector(selectedMarkerWithPlaceInfo:) withObject:self.selPlaceInfo];
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
    else if ([notification.name isEqualToString:NotiSelectPlaceInfo]) {
        self.selPlaceInfo = ((PlaceInfo *)notification.object);
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
