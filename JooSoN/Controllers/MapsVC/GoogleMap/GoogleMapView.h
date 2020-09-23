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
#import "Define.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum {
    MapTypeDestinate
} GoogleMapViewType;

@interface GoogleMapView : LocationView
@property (weak, nonatomic) IBOutlet GMSMapView *gmsMapView;
@property (nonatomic, assign) GoogleMapViewType type;

- (void)setCurrentMarker;
- (void)selectedCurrentMark:(BOOL)selected;
- (void)selectedMarker:(PlaceInfo *)info;
- (void)moveMarker:(PlaceInfo *)info zoom:(NSInteger)zoom;
- (void)hideAllMarker;
- (GMSMarker *)setMarker:(PlaceInfo *)info draggable:(BOOL)draggable;

- (PlaceInfo *)getSelectedPlaceInfo;

@end

NS_ASSUME_NONNULL_END
