//
//  KakaoMapView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/20.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DaumMap/MTMapView.h>
#import <DaumMap/MTMapCameraUpdate.h>
#import <DaumMap/MTMapReverseGeoCoder.h>
#import "LocationView.h"


NS_ASSUME_NONNULL_BEGIN

@interface KakaoMapView : LocationView <MTMapViewDelegate>
@property (weak, nonatomic) IBOutlet MTMapView *mapView;


- (void)setCurrentMarker:(NSNumber *)selected;
- (void)setMarker:(PlaceInfo *)placeInfo;
- (void)selectedMarker:(MTMapPOIItem *)marker selected:(BOOL)selected;
- (void)hideAllMarker;

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info;

@end

NS_ASSUME_NONNULL_END
