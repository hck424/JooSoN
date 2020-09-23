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
#import "BottomPopupViewController.h"
#import "SpeechAlertView.h"

@interface DestinationViewController () <UITextFieldDelegate,  LocationViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet HTextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIView *currentLocView;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (weak, nonatomic) IBOutlet UIButton *btnMicrophone;

@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrentLoc;
@property (weak, nonatomic) IBOutlet UIView *bottomPopView;
@property (weak, nonatomic) IBOutlet UIButton *btnPopNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnPopNavi;
@property (weak, nonatomic) IBOutlet UIButton *btnPopShow;


@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) GoogleMapView *googleMapView;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSMutableArray *arrSearchResult;
@property (nonatomic, assign) CGFloat maxScrollHeight;
@property (nonatomic, assign) CGFloat minScrollHeight;
@property (nonatomic, strong) NSMutableArray *runningAnimators;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, strong) UIViewPropertyAnimator *transitionAnimator;
@property (nonatomic, assign) BOOL aniLock;

@end
static NSString *cellIdentity = @"MapSearchCell";
@implementation DestinationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.runningAnimators = [NSMutableArray array];
    self.arrSearchResult = [NSMutableArray array];
    
    _tfSearch.inputAccessoryView = _accessoryView;
    _btnPopShow.enabled = NO;
    
    _animationProgress = 0;
    _minScrollHeight = 120;
    _maxScrollHeight = 500;
    _tfSearch.inputAccessoryView = _accessoryView;
    
    _lbCurrentLoc.text = @"";
    [self addSubViewGoogleMapView];
    
//    SpeechViewController *vc = [[SpeechViewController alloc] initWithNibName:@"SpeechViewController" bundle:nil];
    
//    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    
//    [self presentViewController:vc animated:YES completion:nil];

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
    _googleMapView.type = MapTypeDestinate;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    [_googleMapView startCurrentLocationUpdatingLocation];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
}

- (void)requestMapSearchPlace:(NSString *)searQuery {
    
//    [_scrollView layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _curPlaceInfo.y;
    coordinate.longitude = _curPlaceInfo.x;
    
    [[DBManager instance] googleMapSearchPlace:searQuery coordinate:coordinate circle:2000 success:^(NSDictionary *dataDic) {
        if ([[dataDic objectForKey:@"places"] count] > 0) {
            [self.arrSearchResult setArray:[dataDic objectForKey:@"places"]];
            PlaceInfo *firstObj = self.arrSearchResult.firstObject;
            [self.googleMapView setMarker:firstObj draggable:YES];
            [self.googleMapView moveMarker:firstObj zoom:15];
            [weakSelf showSearchResultView];
            self.btnPopShow.enabled = YES;
        }
        else {
            self.btnPopShow.enabled = NO;
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

- (void)showSearchResultView {
    
    NSString *title = [NSString stringWithFormat:@"현재위치: %@", _curPlaceInfo.jibun_address];
    BottomPopupViewController *vc = [[BottomPopupViewController alloc] initWidthType:BottomPopupTypeMapSearch title:title data:_arrSearchResult keys:nil completion:^(UIViewController * _Nonnull vcs, id  _Nonnull selData, MapCellAction action) {
    
        self.selPlaceInfo = selData;
        if (action == MapCellActionDefault) {
            [self.googleMapView setMarker:self.selPlaceInfo draggable:YES];
            [self.googleMapView moveMarker:self.selPlaceInfo zoom:15];
        }
        else if (action == MapCellActionNfc) {
            [self showNfcVC];
        }
        else if (action == MapCellActionNavi) {
            [self showNavi];
        }
        else if (action == MapCellActionSave) {
            [self showSaveVC];
        }
        
        [vcs dismissViewControllerAnimated:YES completion:nil];
    }];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [AppDelegate.instance.rootNavigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - textField did changed
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {

}

#pragma mark - UIButton Actions
- (IBAction)onClickedButtonActions:(id)sender {
    [self.view endEditing:YES];
    if (sender == _btnSearch) {
        if (_tfSearch.text.length > 0) {
            [self requestMapSearchPlace:_tfSearch.text];
        }
        else {
            [self.view makeToast:@"검색어를 입력해주세요." duration:1.0 position:CSToastPositionTop];
        }
    }
    else if (sender == _btnSave) {
        AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
        vc.viewType = ViewTypeAdd;
        vc.placeInfo = self.selPlaceInfo;
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    }
    else if (sender == _btnKeyboardDown) {
        [_tfSearch resignFirstResponder];
    }
    else if (sender == _btnCurrentLoc) {
        [_googleMapView stopCurrentLocationUpdatingLocation];
    }
    else if (sender == _btnPopShow) {
        [self showSearchResultView];
    }
    else if (sender == _btnPopNfc) {
        [self showNfcVC];
    }
    else if (sender == _btnPopNavi) {
        [self showNavi];
    }
    else if (sender == _btnMicrophone) {
        [SpeechAlertView showWithTitle:@"JooSoN" completion:^(NSString * _Nonnull result) {
            if (result.length) {
                self.tfSearch.text = result;
                [self.btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }];

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
            if ([info isEqual:self.selPlaceInfo]) {
                index = i;
                break;
            }
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
    [self.googleMapView setCurrentMarker];
    [self.googleMapView moveMarker:self.curPlaceInfo zoom:15];
    [self.googleMapView setMarker:self.curPlaceInfo draggable:YES];
}

- (void)mapViewSelectedPlaceInfo:(PlaceInfo *)info {
    self.selPlaceInfo = info;
}

- (void)showNfcVC {
    NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
    vc.passPlaceInfo = self.selPlaceInfo;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
}

- (void)showSaveVC {
    AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
    vc.viewType = ViewTypeAdd;
    vc.placeInfo = self.selPlaceInfo;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
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
