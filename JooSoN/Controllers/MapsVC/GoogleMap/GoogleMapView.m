//
//  GoogleMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/15.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "GoogleMapView.h"
#import <LMGeocoder/LMGeocoder.h>

@interface GoogleMapView () <GMSMapViewDelegate>
@property (nonatomic, strong) GMSMarker *curMarker;
@property (nonatomic, strong) GMSMarker *selMarker;
@property (nonatomic, strong) NSMutableArray *arrMarker;
@end

@implementation GoogleMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.5666102
                                                            longitude:126.9783881
                                                                 zoom:15];
    [_gmsMapView setCamera:camera];
    self.gmsMapView.delegate = self;
    self.arrMarker = [NSMutableArray array];
    _gmsMapView.myLocationEnabled = NO;
}

- (void)setCurrentMarker:(BOOL)selected {
    UIImage *img = selected? [UIImage imageNamed:@"icon_location_my_s"] : [UIImage imageNamed:@"icon_location_my"];
    self.curMarker = [self setMarker:self.curPlaceInfo icon:img];
    if (selected) {
        [_gmsMapView setSelectedMarker:_curMarker];
    }
}

- (void)moveMarker:(PlaceInfo *)info zoom:(NSInteger)zoom {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = info.y;
    coordinate.longitude = info.x;
    
    GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:zoom];
    [_gmsMapView animateWithCameraUpdate:move];
}

- (GMSMarker *)setMarker:(PlaceInfo *)info icon:(UIImage *)icon {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = info.y;
    coordinate.longitude = info.x;
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = icon;
    marker.position = coordinate;
    marker.title = info.name;
    marker.snippet = info.jibun_address;
    
    NSString *title = info.name;
    if (title == nil) {
        title = info.jibun_address;
    }
    [_gmsMapView addObserver:self forKeyPath:@"selectedMarker" options:NSKeyValueObservingOptionNew context:0];
    marker.userData = @{@"tag" : title, @"placeInfo" : info};
    marker.map = _gmsMapView;
    
    [_arrMarker addObject:marker];
    return marker;
}

//- (void)selectedMarker:(GMSMarker *)marker selected:(BOOL)selected {
//    PlaceInfo *placeInfo = [marker.userData objectForKey:@"placeInfo"];
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude = placeInfo.y;
//    coordinate.longitude = placeInfo.x;
//
//    UIImage *img = selected? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
//    marker.icon = img;
//
//    if (selected) {
//        GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate];
//        [_gmsMapView animateWithCameraUpdate:move];
//        [_gmsMapView setSelectedMarker:marker];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:placeInfo];
//    }
//}

- (void)hideAllMarker {
    for (GMSMarker *marker in _arrMarker) {
        marker.map = nil;
    }
    [_arrMarker removeAllObjects];
    [_gmsMapView clear];
}

//- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info {
//
//    GMSMarker *selMarker = nil;
//    for (GMSMarker *marker in _arrMarker) {
//        [self selectedMarker:marker selected:NO];
//        PlaceInfo *info1 = [marker.userData objectForKey:@"placeInfo"];
//
//        if ([info1 isEqual:info]) {
//            selMarker = marker;
//        }
//    }
//    [self selectedMarker:selMarker selected:YES];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[GMSMarker class]]) {
        GMSMarker *selMarker = [change objectForKey:NSKeyValueChangeNewKey];
        for (GMSMarker *marker in _arrMarker) {
//            [self selectedMarker:marker selected:NO];
        }
        if ([selMarker isEqual:_curMarker] == NO) {
            selMarker.icon = [UIImage imageNamed:@"icon_location_now"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:[selMarker.userData objectForKey:@"placeInfo"]];
    }
}

- (void)movingMarkerShow:(PlaceInfo *)placeInfo {
    if (placeInfo) {
        if (self.selMarker) {
            self.selMarker = nil;
            [self.gmsMapView clear];
        }
        
//        GMSMarker *marker = [self getGmMarkerWithPlaceInfo:placeInfo icon:[UIImage imageNamed:@"icon_location_now_s"]];
//        marker.draggable = YES;
//        marker.map = self.gmsMapView;
//        self.selMarker = marker;
//        [self.gmsMapView setSelectedMarker:marker];
//
        [self setCurrentMarker:NO];
    }
}
#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self getPlaceInfoByCoordinate:coordinate completion:^(PlaceInfo * _Nonnull placeInfo) {
        [self movingMarkerShow:placeInfo];
    }];
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    
}
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    [self getPlaceInfoByCoordinate:marker.position completion:^(PlaceInfo * _Nonnull placeInfo) {
        [self movingMarkerShow:placeInfo];
    }];
}
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    
}
@end
