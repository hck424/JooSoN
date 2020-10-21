//
//  LocationView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/20.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "LocationView.h"
#import "AppDelegate.h"
@implementation LocationView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)startCurrentLocationUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}
- (void)stopCurrentLocationUpdatingLocation {
    [self.locationManager stopUpdatingLocation];

}

- (void)getPlaceInfoByCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(PlaceInfo *placeInfo))completion {

    [[LMGeocoder sharedInstance] cancelGeocode];
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:coordinate
                                                  service:LMGeocoderServiceGoogle
                                       alternativeService:LMGeocoderServiceApple
                                        completionHandler:^(NSArray *results, NSError *error) {
        
        // Parse formatted address
        if (results.count && !error) {
            LMAddress *address = [results firstObject];
            
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
            
            PlaceInfo *info = [[PlaceInfo alloc] init];
            
            info.x = coordinate.latitude;
            info.y = coordinate.longitude;
            
            NSMutableString *curAddr = [NSMutableString string];
            if (state.length > 0) {
                [curAddr setString:state];
                info.state = state;
            }
            
            if (city.length > 0) {
                [curAddr appendFormat:@" %@", city];
                info.city = city;
            }
            
            if (street.length > 0) {
                [curAddr appendFormat:@" %@", street];
                info.street = street;
                info.name = name;
            }
            else if (name.length > 0) {
                [curAddr appendFormat:@" %@", name];
                info.name = name;
            }
            else {
                if (thoroughfare.length > 0) {
                    [curAddr appendFormat:@" %@", thoroughfare];
                    info.name = thoroughfare;
                }
                if (subThoroughfare.length > 0) {
                    info.name = thoroughfare;
                    [curAddr appendFormat:@" %@", subThoroughfare];
                }
            }
            
            if (subLocality.length > 0) {
                info.subLocality = subLocality;
            }
            else if (thoroughfare.length > 0) {
                info.subLocality = thoroughfare;
            }
            info.jibun_address = curAddr;
            
            if (completion) {
                completion(info);
            }
        }
        else {
            if (completion) {
                completion(nil);
            }
        }
        
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
    [self getPlaceInfoByCoordinate:coordinate completion:^(PlaceInfo *placeInfo) {
        if (placeInfo != nil) {
            self.curPlaceInfo = placeInfo;
            AppDelegate.instance.curPlaceInfo = self.curPlaceInfo;
            if ([self.delegate respondsToSelector:@selector(locationView:curPlaceInfo:)]) {
                [self.delegate locationView:self curPlaceInfo:self.curPlaceInfo];
            }
        }
    }];
    
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
