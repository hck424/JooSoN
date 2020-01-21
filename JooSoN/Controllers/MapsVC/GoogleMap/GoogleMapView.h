//
//  GoogleMapView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/15.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationView.h"

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "PlaceInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface GoogleMapView : LocationView
@property (weak, nonatomic) IBOutlet GMSMapView *gmsMapView;

- (void)setCurrentMarker:(NSNumber *)selected;
- (void)setMarker:(PlaceInfo *)placeInfo;
- (void)selectedMarker:(GMSMarker *)marker selected:(BOOL)selected;
- (void)hideAllMarker;

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info;

@end

NS_ASSUME_NONNULL_END
