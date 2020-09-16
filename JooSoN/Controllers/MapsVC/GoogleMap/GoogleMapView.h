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

- (void)setCurrentMarker:(BOOL)selected;
//- (void)setMarker:(PlaceInfo *)placeInfo;
- (void)hideAllMarker;
- (GMSMarker *)setMarker:(PlaceInfo *)info icon:(UIImage *)icon;
- (void)moveMarker:(PlaceInfo *)info zoom:(NSInteger)zoom;
//- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info;

@end

NS_ASSUME_NONNULL_END
