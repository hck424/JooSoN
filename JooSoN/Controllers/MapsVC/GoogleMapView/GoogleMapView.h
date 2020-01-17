//
//  GoogleMapView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/15.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "PlaceInfo.h"

NS_ASSUME_NONNULL_BEGIN
@protocol GoogleMapViewDelegate <NSObject>
@optional
- (void)googleMapView:(id)googleMapView curPlaceInfo:(PlaceInfo *)curPlaceInfo;
@end
@interface GoogleMapView : UIView
@property (weak, nonatomic) IBOutlet GMSMapView *gmsMapView;
@property (weak, nonatomic) id <GoogleMapViewDelegate>delegate;

- (void)startCurrentLocationUpdatingLocation;
- (void)stopCurrentLocationUpdatingLocation;
@end

NS_ASSUME_NONNULL_END
