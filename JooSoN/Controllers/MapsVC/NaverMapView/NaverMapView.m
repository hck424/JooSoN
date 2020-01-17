//
//  NaverMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/08.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "NaverMapView.h"
#import "LMGeocoder.h"
#import "LMAddress.h"

@interface NaverMapView () <NMFLocationManagerDelegate, CLLocationManagerDelegate>

//@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation NaverMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadData];
}

- (void)loadData {
    self.defaultCameraPosition = [NMFCameraPosition cameraPosition:NMGLatLngMake(37.5666102, 126.9783881) zoom:14 tilt:0 heading:0];
    self.map = _mapView.mapView;
    [_map moveCamera:[NMFCameraUpdate cameraUpdateWithPosition:_defaultCameraPosition]];
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    self.locationManager.distanceFilter = 10;
//    [self.locationManager requestWhenInUseAuthorization];
//    [self.locationManager startUpdatingLocation];
//
    
}

- (void)startCurrentLocationUpdatingLocation {
    NMFLocationManager *lm = [NMFLocationManager sharedInstance];
    [lm locationUpdateAuthorization];
    [lm addDelegate:self];
    [lm startUpdatingLocation];
    [lm startUpdatingHeading];
}
- (void)stopCurrentLocationUpdatingLocation {
    NMFLocationManager *lm = [NMFLocationManager sharedInstance];
    [lm stopUpdatingLocation];
    [lm stopUpdatingHeading];
}

- (void)passingAdress:(LMAddress *)address codinate:(CLLocationCoordinate2D)codinate {
    
    //    NSString *tmpStr = address.formattedAddress;
    NSDictionary *adDic = [address.rawSource valueForKey:@"addressDictionary"];
    NSString *street = [adDic objectForKey:@"Street"];
    NSString *subLocality = [adDic objectForKey:@"SubLocality"];
    NSString *state = [adDic objectForKey:@"State"];
    NSString *subThoroughfare = [adDic objectForKey:@"SubThoroughfare"];
    NSString *city = [adDic objectForKey:@"City"];
    NSString *thoroughfare = [adDic objectForKey:@"Thoroughfare"];
    NSString *name = [adDic objectForKey:@"Name"];
    //    NSString *countryCode = [adDic objectForKey:@"CountryCode"];
    //    NSString *country = [adDic objectForKey:@"Country"];
    //    NSString *zip = [adDic objectForKey:@"ZIP"];
    
    self.curPlaceInfo = [[PlaceInfo alloc] init];
    
    _curPlaceInfo.x = codinate.longitude;
    _curPlaceInfo.y = codinate.latitude;
    
    NSMutableString *curAddr = [NSMutableString string];
    if (state.length > 0) {
        [curAddr setString:state];
        _curPlaceInfo.state = state;
    }
    
    if (city.length > 0) {
        [curAddr appendFormat:@" %@", city];
        _curPlaceInfo.city = city;
    }
    
    if (street.length > 0) {
        [curAddr appendFormat:@" %@", street];
        _curPlaceInfo.street = street;
        _curPlaceInfo.name = name;
    }
    else if (name.length > 0) {
        [curAddr appendFormat:@" %@", name];
        _curPlaceInfo.name = name;
    }
    else {
        if (thoroughfare.length > 0) {
            [curAddr appendFormat:@" %@", thoroughfare];
            _curPlaceInfo.name = thoroughfare;
        }
        if (subThoroughfare.length > 0) {
            _curPlaceInfo.name = thoroughfare;
            [curAddr appendFormat:@" %@", subThoroughfare];
        }
    }
    
    if (subLocality.length > 0) {
        _curPlaceInfo.subLocality = subLocality;
    }
    else if (thoroughfare.length > 0) {
        _curPlaceInfo.subLocality = thoroughfare;
    }
    
    _curPlaceInfo.jibun_address = curAddr;
    if ([self.delegate respondsToSelector:@selector(naverMapView:curPlaceInfo:)]) {
        [_delegate naverMapView:self curPlaceInfo:_curPlaceInfo];
    }
}

- (void)getAddressToCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [[LMGeocoder sharedInstance] cancelGeocode];
    
    
    __weak typeof (self) weakSelf = self;
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                                  service:LMGeocoderServiceGoogle
                                       alternativeService:LMGeocoderServiceApple
                                        completionHandler:^(NSArray *results, NSError *error) {
        
        // Parse formatted address
        NSString *formattedAddress = @"-";
        if (results.count && !error) {
            LMAddress *address = [results firstObject];
            [weakSelf passingAdress:address codinate:coordinate];
        }
        NSLog(@"%@", formattedAddress);
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
//}

//// Responding to Location Events
//- (void)locationManager:(NMFLocationManager *)locationManager didUpdateLocations:(NSArray *)locations {
    //    NSLog(@"didUpdateLocations %@", locations);
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"curent location x : %@", locations);
    
//    NSLog(@"curent location x : @%lf, y : %lf", coordinate.latitude, coordinate.longitude);
    self.curCoordinate = coordinate;
    [self getAddressToCoordinate:coordinate];

    
    //    [self.mapView setMapCenter:myLocation];
    //    [[self.mapView mapOverlayManager] setMyLocation:_myLocationPoint locationAccuracy:0];
    //
    //    self.myLocationPoint = myLocation;
    //    self.indicatorPoint = _myLocationPoint;
    //    [self setMarker];
    
    //    [self getCurrentAddressToCoordinate:latlng];
}
- (void)locationManager:(NMFLocationManager *)locationManager didFailWithError:(NSError *)error {
    //    NSLog(@"didFailWithError %@", error);
}

//// Responding to Heading Events
//- (void)locationManager:(NMFLocationManager *)locationManager didUpdateHeading:(CLHeading *)newHeading {
//    NSLog(@"didUpdateHeading %@", newHeading);
//}
//// Authorization Status Change
//- (void)locationManager:(NMFLocationManager *)locationManager didChangeAuthStatus:(CLAuthorizationStatus)status {
//    NSLog(@"didChangeAuthStatus %d", status);
//}
//
- (void)locationManagerDidStartLocationUpdates:(NMFLocationManager *)locationManager {
    NSLog(@"locationManagerDidStartLocationUpdates");
}
//- (void)locationManagerDidStartHeadingUpdates:(NMFLocationManager *)locationManager {
//    NSLog(@"locationManagerDidStartHeadingUpdates");
//}
//- (void)locationManagerBackgroundLocationUpdatesDidTimeout:(NMFLocationManager *)locationManager {
//    NSLog(@"locationManagerBackgroundLocationUpdatesDidTimeout");
//}
//- (void)locationManagerBackgroundLocationUpdatesDidAutomaticallyPause:(NMFLocationManager *)locationManager {
//    NSLog(@"locationManagerBackgroundLocationUpdatesDidAutomaticallyPause");
//}
//- (void)locationManagerDidStopLocationUpdates:(NMFLocationManager *)locationManager {
//    NSLog(@"locationManagerDidStopLocationUpdates");
//}
//- (void)locationManagerDidStopHeadingUpdates:(NMFLocationManager *)locationManager {
//    NSLog(@"locationManagerDidStopHeadingUpdates");
//}





///**
// 지도가 표시하는 영역이 변경될 때 호출되는 콜백 메서드.
//
// @param mapView 영역이 변경될 `NMFMapView` 객체.
// @param animated 애니메이션 효과가 적용돼 움직일 경우 `YES`, 그렇지 않을 경우 `NO`.
// @param reason 움직임의 원인.
// */
//- (void)mapView:(NMFMapView *)mapView regionWillChangeAnimated:(BOOL)animated byReason:(NSInteger)reason {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
///**
// 지도가 표시하고 있는 영역이 변경되고 있을 때 호출되는 콜백 메서드.
//
// @param mapView 영역이 변경되고 있는 `NMFMapView` 객체.
// @param reason 움직임의 원인.
// */
//- (void)mapViewRegionIsChanging:(NMFMapView *)mapView byReason:(NSInteger)reason {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
///**
// 지도가 표시하고 있는 영역이 변경되었을 때 호출되는 콜백 메서드.
//
// @param mapView 영역이 변경된 `NMFMapView` 객체.
// @param animated 애니메이션 효과가 적용돼 움직인 경우 `YES`, 그렇지 않은 경우 `NO`.
// @param reason 움직임의 원인.
// */
//- (void)mapView:(NMFMapView *)mapView regionDidChangeAnimated:(BOOL)animated byReason:(NSInteger)reason {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
///**
// 현재 진행 중인 지도 이동 애니메이션이 취소되었을때 호출되는 콜백 메서드.
//
// @param mapView 영역이 변경되고 있었던 `NMFMapView` 객체.
// @param reason 취소된 원인.
// */
//- (void)mapViewCameraUpdateCancel:(NMFMapView *)mapView byReason:(NSInteger)reason {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
///**
// 지도가 표시하고 있는 영역이 변경된 후 진행 중인 터치 이벤트가 없을 때 호출되는 콜백 메서드.
//
// @param mapView 영역이 변경된 `NMFMapView` 객체.
// */
//- (void)mapViewIdle:(NMFMapView *)mapView {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//#pragma mark Responding to Map TouchEvent
//
///**
// 사용자가 지도의 심벌을 탭하면 호출됩니다.
//
// @param mapView `NMFMapView` 객체.
// @param symbol 탭한 지도 심벌 객체.
// @return `YES`일 경우 이벤트를 소비합니다. 그렇지 않을 경우 `NMFMapView`까지 이벤트가 전달되어 `NMFMapViewDelegate`의 `didTapMapView`가 호출됩니다.
// */
//- (BOOL)mapView:(NMFMapView *)mapView didTapSymbol:(NMFSymbol *)symbol {
// NSLog(@"%s", __PRETTY_FUNCTION__);
//    return YES;
//}
//
///**
// 사용자가 지도를 탭하면 호출됩니다.
//
// @param point 탭한 화면 좌표.
// @param latlng 탭한 위경도 좌표.
// */
//- (void)didTapMapView:(CGPoint)point LatLng:(NMGLatLng*)latlng {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}





- (void)dealloc {
    self.mapView = nil;
}

@end
