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

NS_ASSUME_NONNULL_BEGIN
@protocol NaverMapViewDelegate <NSObject>
@optional
- (void)naverMapView:(id)naverMapView curPlaceInfo:(PlaceInfo *)curPlaceInfo;
@end
@interface NaverMapView : UIView <NMFMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NMFNaverMapView *mapView;
@property (nonatomic, strong) NMFMapView *map;
@property (nonatomic, weak) id<NaverMapViewDelegate>delegate;

@property (nonatomic, strong) NMFCameraPosition *defaultCameraPosition;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, assign) CLLocationCoordinate2D curCoordinate;

- (void)startCurrentLocationUpdatingLocation;
- (void)stopCurrentLocationUpdatingLocation;
@end

NS_ASSUME_NONNULL_END
