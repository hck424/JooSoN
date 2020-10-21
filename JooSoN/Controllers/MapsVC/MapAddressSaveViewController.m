//
//  MapAddressSaveViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/21.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapAddressSaveViewController.h"
#import "NfcViewController.h"
#import "AddJooSoViewController.h"
#import "GoogleMapView.h"
#import "DBManager.h"
#import "CallkitController.h"
#import "NSString+Utility.h"
#import "UIView+Toast.h"

@interface MapAddressSaveViewController () <LocationViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNumber;
@property (nonatomic, weak) IBOutlet UIButton *btnBack;
@property (nonatomic, weak) IBOutlet UIButton *btnAdd;
@property (nonatomic, weak) IBOutlet UIButton *btnNfc;
@property (nonatomic, weak) IBOutlet UIButton *btnNavi;
@property (nonatomic, weak) IBOutlet UIButton *btnStar;
@property (nonatomic, weak) IBOutlet UILabel *lbPlaceName;
@property (nonatomic, weak) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;

@property (nonatomic, assign) BOOL onClipPhoneNumber;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSString *callType;
@end

@implementation MapAddressSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selPlaceInfo = _passPlaceInfo;
    
    [_btnBack setTitle:_passPlaceInfo.name forState:UIControlStateNormal];
    _lbPlaceName.text = _passPlaceInfo.name;
    _lbAddress.text = _passPlaceInfo.jibun_address;
    _btnPhoneNumber.hidden = YES;
    if (_passPlaceInfo.phone_number != nil) {
        _btnPhoneNumber.hidden = NO;
        NSString *phonenumber = _passPlaceInfo.phone_number;
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:phonenumber attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
        [self.btnPhoneNumber setAttributedTitle:attr forState:UIControlStateNormal];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [_btnPhoneNumber addGestureRecognizer:longPress];
    }
    
    [self addSubViewGoogleMapView];
}

- (void)addSubViewGoogleMapView {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapContainer.bounds;
    _googleMapView.type = MapTypeDestinate;
    _googleMapView.delegate = self;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapContainer addSubview:_googleMapView];
    
    [_googleMapView setMarker:_passPlaceInfo draggable:NO];
    [_googleMapView moveMarker:_passPlaceInfo zoom:15];
}
- (void)longPressGesture:(UILongPressGestureRecognizer *)gestrue {
    UIButton *btn = (UIButton *)gestrue.view;
    if (gestrue.state == UIGestureRecognizerStateChanged) {
        NSLog(@"touchdown: %@", btn.titleLabel.text);
        if (_onClipPhoneNumber == NO && btn.titleLabel.attributedText.string != nil) {
            _onClipPhoneNumber = YES;
            [btn.titleLabel.attributedText.string toClipboard];
            NSString *msg = [NSString stringWithFormat:@"%@ 이 복사되었습니다.", btn.titleLabel.attributedText.string];
            [self.view makeToast:msg duration:2.0 position:CSToastPositionBottom];
        }
    }
    else if (gestrue.state == UIGestureRecognizerStateEnded) {
        _onClipPhoneNumber = NO;
    }
}
- (IBAction)onClickedButtonActions:(UIButton *)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == _btnAdd) {
        AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
        vc.placeInfo = _passPlaceInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender == _btnNfc) {
        NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
        vc.passPlaceInfo = _passPlaceInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender == _btnNavi) {
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
    else if (sender == _btnStar) {
        sender.selected = !sender.selected;
        
        if (sender.selected) {
//            distance : 0.000000
//            jibun_address : 대한민국 경기도 하남시 천현동 181-20
//            name : 하남만남주유소
//            phone_number : (null)
//            road_address : (null)
//            sessionId : (null)
//            x : 127.206947
//            y : 37.530766
//            _passPlaceInfo
            
            NSString *geoLng = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:_passPlaceInfo.x]];
            NSString *geoLat = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:_passPlaceInfo.y]];
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:_passPlaceInfo.name forKey:@"name"];
            [param setObject:_passPlaceInfo.jibun_address forKey:@"address"];
            if (_passPlaceInfo.phone_number != nil) {
                NSDictionary *phoneNumberInfo = [NSDictionary dictionaryWithObjectsAndKeys:_passPlaceInfo.phone_number, @"number", [NSNumber numberWithBool:YES],@"isMainPhone",  @"", @"label", nil];
                [param setObject:@[phoneNumberInfo] forKey:@"phoneNumbers"];
            }
            
            [param setObject:geoLat forKey:@"geoLat"];
            [param setObject:geoLng forKey:@"geoLng"];
            [param setObject:[NSNumber numberWithBool:YES] forKey:@"like"];
            
            [DBManager.instance insertJooSo:param success:^{
                NSLog(@"success: insert jooso");
            } fail:^(NSError *error) {
                NSLog(@"fail: insert jooso %@", error.debugDescription);
            }];
        }
        else {
            [DBManager.instance getAllLike:^(NSArray *arrData)
             {
                JooSo *findJooso = nil;
                if (arrData.count > 0) {
                    for (JooSo *jooso in arrData) {
                        if ([jooso.name isEqualToString:self.passPlaceInfo.name]) {
                            findJooso = jooso;
                            break;
                        }
                    }
                }
                
                if (findJooso != nil) {
                    [[DBManager instance] deleteJooSo:findJooso success:^{
                        NSLog(@"success: insert jooso");
                    } fail:^(NSError *error) {
                        NSLog(@"fail: insert jooso %@", error.debugDescription);
                    }];
                }
            } fail:^(NSError *error) {
                
            }];
        }
    }
    else if (sender == _btnPhoneNumber && self.selPlaceInfo.phone_number != nil) {
        NSLog(@"%@", self.selPlaceInfo.phone_number);
        NSString *url = [NSString stringWithFormat:@"tel://%@", self.selPlaceInfo.phone_number];
        self.callType = @"1";
        if (self.callkitController == nil) {
            self.callkitController = [[CallkitController alloc] init];
            self.arrCallState = [NSMutableArray array];
        }
        [[AppDelegate instance] openSchemeUrl:url];
    }
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
