//
//  NaverMapView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/08.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NMapsMap/NMapsMap.h>
#import "PlaceInfo.h"
#import "LocationView.h"

NS_ASSUME_NONNULL_BEGIN
@interface NaverMapView : LocationView <NMFMapViewDelegate>
@property (weak, nonatomic) IBOutlet NMFNaverMapView *mapView;
@property (nonatomic, strong) NMFMapView *map;
@property (nonatomic, strong) NMFCameraPosition *defaultCameraPosition;

- (void)setCurrentMarker:(NSNumber *)selected;
- (void)setMarker:(PlaceInfo *)placeInfo;
- (void)selectedMarker:(NMFMarker *)marker selected:(BOOL)selected;
- (void)hideAllMarker;

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info;
@end

NS_ASSUME_NONNULL_END
