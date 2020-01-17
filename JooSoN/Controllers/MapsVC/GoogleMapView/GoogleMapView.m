//
//  GoogleMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/15.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "GoogleMapView.h"
#import <LMGeocoder/LMGeocoder.h>

@interface GoogleMapView () <GMSMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D curCoordinate;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;

@end

@implementation GoogleMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.5666102
                                                            longitude:126.9783881
                                                                 zoom:15];
    [_gmsMapView setCamera:camera];
    self.gmsMapView.delegate = self;
    _gmsMapView.myLocationEnabled = NO;

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 10;
    [self.locationManager requestWhenInUseAuthorization];
    
    
    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(37.5666102, 126.9783881);
//    marker.title = @"";
//    marker.snippet = @"Australia";
//    marker.map = mapView;
}

- (void)startCurrentLocationUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}
- (void)stopCurrentLocationUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
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
    if ([self.delegate respondsToSelector:@selector(googleMapView:curPlaceInfo:)]) {
        [_delegate googleMapView:self curPlaceInfo:_curPlaceInfo];
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
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations API_AVAILABLE(ios(6.0), macos(10.9)) {
    
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"curent location x : %@", locations);
    
    //    NSLog(@"curent location x : @%lf, y : %lf", coordinate.latitude, coordinate.longitude);
    self.curCoordinate = coordinate;
    [self getAddressToCoordinate:coordinate];
}

/*
 *  locationManager:didUpdateHeading:
 *
 *  Discussion:
 *    Invoked when a new heading is available.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading API_AVAILABLE(ios(3.0), watchos(2.0)) API_UNAVAILABLE(tvos, macos) {
    
}

@end
