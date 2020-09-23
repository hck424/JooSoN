//
//  LocationView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/20.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LMGeocoder.h>
#import "PlaceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LocationViewDelegate <NSObject>
@optional
- (void)locationView:(id)locationView curPlaceInfo:(PlaceInfo *)curPlaceInfo;
- (void)mapViewSelectedPlaceInfo:(PlaceInfo *)info;
@end

@interface LocationView : UIView <CLLocationManagerDelegate>
- (void)getPlaceInfoByCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(PlaceInfo *placeInfo))completion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D curCoordinate;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) id <LocationViewDelegate>delegate;
- (void)startCurrentLocationUpdatingLocation;
- (void)stopCurrentLocationUpdatingLocation;

@end

NS_ASSUME_NONNULL_END
