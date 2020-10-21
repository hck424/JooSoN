//
//  InfoJooSoViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/03.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "InfoJooSoViewController.h"
#import "HAlertView.h"
#import "DBManager.h"
#import "ContactsManager.h"
#import "NSString+Utility.h"
#import "CallkitController.h"
#import "AddJooSoViewController.h"
#import "NfcViewController.h"
#import "GoogleMapView.h"
#import "UIView+Toast.h"

@interface InfoJooSoViewController () <CallkitControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnModi;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UILabel *lbPhoneNumber;

@property (weak, nonatomic) IBOutlet UIButton *btnEmptyMarker;
@property (weak, nonatomic) IBOutlet VerticalButton *btnSms;
@property (weak, nonatomic) IBOutlet VerticalButton *btnCall;
@property (weak, nonatomic) IBOutlet VerticalButton *btnFace;
@property (weak, nonatomic) IBOutlet VerticalButton *btnNfc;
@property (weak, nonatomic) IBOutlet VerticalButton *btnNavi;
@property (weak, nonatomic) IBOutlet VerticalButton *btnShare;

@property (nonatomic, strong) ContactsManager *contactsManager;
@property (nonatomic, strong) CallkitController *callkitController;
@property (nonatomic, strong) NSString *callType;
@property (nonatomic, assign) NSTimeInterval callConectedTimeInterval;
@property (nonatomic, strong) NSMutableArray *arrCallState;
@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) UIView *selMapView;
@end

@implementation InfoJooSoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.callkitController = [[CallkitController alloc] init];
    
    if (_passJooso != nil) {
        if (_passJooso.name.length > 0) {
            [_btnBack setTitle:_passJooso.name forState:UIControlStateNormal];
        }
        else if ([[_passJooso getMainPhone] length] > 0) {
            [_btnBack setTitle:[_passJooso getMainPhone] forState:UIControlStateNormal];
        }
        else {
            [_btnBack setTitle:@"정보보기" forState:UIControlStateNormal];
        }
    }
    else if (_passHistory != nil) {
        if (_passHistory.name.length > 0) {
            [_btnBack setTitle:_passHistory.name forState:UIControlStateNormal];
        }
        else if (_passHistory.phoneNumber.length > 0) {
            [_btnBack setTitle:_passHistory.phoneNumber forState:UIControlStateNormal];
        }
        else {
            [_btnBack setTitle:@"정보보기" forState:UIControlStateNormal];
        }
    }
    else {
        [_btnBack setTitle:@"정보보기" forState:UIControlStateNormal];
    }
    
    self.title = nil;
    
    _callkitController.delegate = self;
    self.arrCallState = [NSMutableArray array];
    [self setData];
    
}


- (void)setData {
    
    _ivProfile.layer.cornerRadius = _ivProfile.frame.size.height/2;
    _ivProfile.layer.borderColor = RGB(216, 216, 216).CGColor;
    _ivProfile.layer.borderWidth = 1.0f;
    
    _btnLike.layer.cornerRadius = _btnLike.frame.size.height/2;
    _btnLike.layer.borderColor = RGB(216, 216, 216).CGColor;
    _btnLike.layer.borderWidth = 1.0f;
    
    _btnCall.enabled = NO;
    _btnSms.enabled = NO;
    _btnFace.enabled = NO;
    _btnNfc.enabled = NO;
    _btnNavi.enabled = NO;
    _lbAddress.text = @"";
    _lbPhoneNumber.text = @"";
    
    _ivProfile.image = [UIImage imageNamed:@"icon_profile_people_s"];
    if (_passJooso != nil) {
        if (_passJooso.toThumnail.image != nil) {
            _ivProfile.image = _passJooso.toThumnail.image;
        }
        
        BOOL like = _passJooso.like;
        _btnLike.selected = like;
            
        if (_passJooso.address.length > 0 && _passJooso.geoLng != 0 && _passJooso.geoLng != 0) {
            _lbAddress.text = _passJooso.address;
            
            _btnNfc.enabled = YES;
            _btnNavi.enabled = YES;
        }
        else {
            _lbAddress.text = [_passJooso getMainPhone];
        }
        
        _lbPhoneNumber.text = [_passJooso getMainPhone];
        
        if ([[_passJooso getMainPhone] length] > 0) {
            _btnCall.enabled = YES;
            _btnSms.enabled = YES;
            _btnFace.enabled = YES;
        }
        
        _btnEmptyMarker.hidden = NO;
        if ((_passJooso.address.length > 0 || _passJooso.roadAddress.length > 0)
            && _passJooso.geoLng > 0
            && _passJooso.geoLng > 0) {
            
            _btnEmptyMarker.hidden = YES;
            
            [self addSubViewGoogleMap];
        }
    }
    else if (_passHistory != nil) {
        if (_passHistory.phoneNumber != nil) {
            _btnCall.enabled = YES;
            _btnSms.enabled = YES;
            _btnFace.enabled = YES;
        }
        
        if ((_passHistory.address.length > 0)
            && _passHistory.geoLat > 0
            && _passHistory.geoLng > 0) {
            
            _btnEmptyMarker.hidden = YES;
            [self addSubViewGoogleMap];
            
            _lbAddress.text = _passHistory.address;
            
            _btnNfc.enabled = YES;
            _btnNavi.enabled = YES;
        }
    }
    
    [self.view layoutIfNeeded];
    
}

- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _btnDel) {
        NSString *title = @"";
        
        if (_passJooso != nil) {
            if (_passJooso.name.length > 0) {
                title = _passJooso.name;
            }
            else if ([_passJooso getMainPhone].length > 0) {
                title = [_passJooso getMainPhone];
            }
            else {
                title = _passJooso.address;
            }
        }
        else if (_passHistory != nil) {
            //historytype =? 0: 전화타입, 1: sms, 2: facephone, 3: nfc, 4: navi
            if (_passHistory.historyType == 0
                || _passHistory.historyType == 1
                || _passHistory.historyType == 2
                || _passHistory.historyType == 3) {
                
                title = _passHistory.phoneNumber;
            }
            else if (_passHistory.historyType == 3
                     || _passHistory.historyType == 4) { //nfc
                title = _passJooso.address;
            }
        }
        
        __weak typeof(self) weakSelf = self;
        [HAlertView alertShowWithTitle:title message:@"정말 삭제 하시겠습니까?" btnTitles:@[@"확인", @"취소"] alertBlock:^(NSInteger index) {
            if (index == 0) {
                if (self.passJooso != nil) {
                    [weakSelf deleteJoso];
                }
                else {
                    [weakSelf deleteHistory];
                }
            }
        }];
    }
    else if (sender == _btnModi) {
        AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
        if (_passJooso != nil) {
            vc.passJooso = _passJooso;
            vc.viewType = ViewTypeModi;
        }
        else {
            vc.passHistory = _passHistory;
            vc.viewType = ViewTypeAdd;
        }
        
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if (sender == _btnCall
             || sender == _btnSms
             || sender == _btnFace) {
        
        NSString *phoneNumber = @"";
        if (_passJooso != nil) {
            phoneNumber = [_passJooso getMainPhone];
        }
        else if (_passHistory != nil) {
            phoneNumber = _passHistory.phoneNumber;
        }
        
        if (phoneNumber.length > 0) {
            NSString *url = @"";
            if (sender == _btnCall) {
                url = [NSString stringWithFormat:@"tel://%@", phoneNumber];
                self.callType = @"1";
                [[AppDelegate instance] openSchemeUrl:url];
            }
            else if (sender == _btnFace) {
                url = [NSString stringWithFormat:@"facetime://%@", phoneNumber];
                self.callType = @"2";
                [[AppDelegate instance] openSchemeUrl:url];
            }
            else if (sender == _btnSms) {
                url = [NSString stringWithFormat:@"sms://%@", phoneNumber];
                [AppDelegate.instance openSchemeUrl:url completion:^(BOOL success) {
                    if (success) {
                        if (self.passJooso != nil) {
                            [self saveHisotryWithJooso:self.passJooso type:1];
                        }
                        else if (self.passHistory != nil) {
                            [self saveHisotryWithHistory:self.passHistory type:1];
                        }
                    }
                }];
            }
        }
    }
    else if (sender == _btnLike) {
        if (_passJooso != nil) {
            _btnLike.selected = !_btnLike.selected;
            _passJooso.like = _btnLike.selected;
            [[DBManager instance] updateLike:_passJooso success:^{
                NSLog(@"success update like");
            } fail:^(NSError *error) {
                NSLog(@"error: update like > %@", error);
            }];
        }
    }
    else if (sender == _btnNfc) {
        NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
        PlaceInfo *info = [[PlaceInfo alloc] init];
        if (_passJooso != nil) {
            info.x = _passJooso.geoLat;
            info.y = _passJooso.geoLng;
            info.jibun_address = _passJooso.address;
            info.name = _passJooso.placeName;
        }
        else if (_passHistory != nil) {
            info.x = _passHistory.geoLat;
            info.y = _passHistory.geoLng;
            info.name = _passHistory.address;
        }
        vc.passPlaceInfo = info;
        [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
    }
    else if (sender == _btnNavi) {
        
        PlaceInfo *info = [[PlaceInfo alloc] init];
        if (_passJooso != nil) {
            info.x = _passJooso.geoLat;
            info.y = _passJooso.geoLng;
            info.jibun_address = _passJooso.address;
            info.name = _passJooso.placeName;
        }
        else if (_passHistory != nil) {
            info.x = _passHistory.geoLng;
            info.y = _passHistory.geoLat;
            info.name = _passHistory.address;
        }
        
        NSString *url = [self getNaviUrlWithPalceInfo:info];
        if (url.length > 0) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            [[AppDelegate instance] openSchemeUrl:url completion:^(BOOL success) {
                if (success == NO) {
                    [self.view makeToast:@"지도가 설치되어 있지 않습니다."];
                }
                else {
                    [self saveHistory];
                }
            }];
        }
    }
    else if (sender == _btnShare) {
        
    }
}
- (void)saveHistory {
    if (self.passJooso != nil) {
        [self saveHisotryWithJooso:self.passJooso type:4];
    }
    else if (self.passHistory != nil) {
        [self saveHisotryWithHistory:self.passHistory type:4];
    }
}
- (void)deleteHistory {
    if (_passHistory == nil) {
        return;
    }
    [DBManager.instance deleteHistory:_passHistory success:nil fail:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)deleteJoso {
    
    NSString *phoneNumber = [_passJooso getMainPhone];
    phoneNumber = [phoneNumber delPhoneFormater];
    
    NSString *name = _passJooso.name;

    name = [name isEqual:[NSNull null]]? @"" : name;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (name != nil) {
        [param setObject:name forKey:@"name"];
    }
    else {
        [param setObject:@"" forKey:@"name"];
    }
    if (phoneNumber != nil) {
        [param setObject:phoneNumber forKey:@"phoneNumber"];
    }
    
    if (phoneNumber.length > 0) {
        if (_contactsManager == nil) {
            self.contactsManager = [[ContactsManager alloc] init];
        }
        
        [_contactsManager deleteAddressBook:param completion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"success delete jooso addressbook");
            }
            else {
                NSLog(@"error: delte jooso address book> %@", error);
            }
        }];
    }
    
    [[DBManager instance] deleteJooSo:_passJooso success:^{
        [self.navigationController popViewControllerAnimated:YES];
    } fail:^(NSError *error) {
        NSLog(@"error: delte jooso > %@", error);
    }];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    
    NSLog(@"%@: %@", NSStringFromClass([self class]), state);
    
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        NSDate *curDate = [NSDate date];
        if (_passJooso != nil) {
            
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
            
            
            [param setObject:_passJooso.name forKey:@"name"];
            [param setObject:[_passJooso getMainPhone]  forKey:@"phoneNumber"];
            [param setObject:callState forKey:@"callState"];
            _callType = [_callType isEqual:[NSNull null]] ? @"1" : _callType;
            [param setObject:_callType forKey:@"callType"];
            [param setObject:[NSDate date] forKey:@"createDate"];
            [param setObject:[NSNumber numberWithDouble:takeCalling] forKey:@"takeCalling"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"callCnt"];
            [param setObject:[NSNumber numberWithInt:0] forKey:@"historyType"];
            [param setObject:[NSNumber numberWithDouble:_passJooso.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:_passJooso.geoLng] forKey:@"geoLng"];
            if (_passJooso.address != nil) {
                [param setObject:_passJooso.address forKeyedSubscript:@"address"];
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

#pragma mark - mapview add
- (void)addSubViewGoogleMap {
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapView.bounds;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapView addSubview:_googleMapView];
    self.selMapView = _googleMapView;
    [self setMarker];
}

- (void)setMarker {
    PlaceInfo *info = [[PlaceInfo alloc] init];
    if (_passJooso != nil) {
        info.x = _passJooso.geoLat;
        info.y = _passJooso.geoLng;
        info.jibun_address = _passJooso.address;
        info.name = _passJooso.placeName;
    }
    else if (_passHistory != nil) {
        info.x = _passHistory.geoLng;
        info.y = _passHistory.geoLat;
        info.name = _passHistory.address;
    }
    [_googleMapView setMarker:info draggable:NO];
    [_googleMapView moveMarker:info zoom:15];
}

@end
