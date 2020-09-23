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

@interface MapAddressSaveViewController () <LocationViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *btnBack;
@property (nonatomic, weak) IBOutlet UIButton *btnAdd;
@property (nonatomic, weak) IBOutlet UIButton *btnNfc;
@property (nonatomic, weak) IBOutlet UIButton *btnNavi;
@property (nonatomic, weak) IBOutlet UIButton *btnStar;
@property (nonatomic, weak) IBOutlet UILabel *lbPlaceName;
@property (nonatomic, weak) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;

@property (nonatomic, strong) GoogleMapView *googleMapView;

@end

@implementation MapAddressSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_btnBack setTitle:_passPlaceInfo.name forState:UIControlStateNormal];
    _lbPlaceName.text = _passPlaceInfo.name;
    _lbAddress.text = _passPlaceInfo.jibun_address;
    
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
}
@end
