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
    _gmsMapView.myLocationEnabled = NO;
// Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(37.5666102, 126.9783881);
//    marker.title = @"";
//    marker.snippet = @"Australia";
//    marker.map = mapView;
}

- (void)setCurrentMarker:(NSNumber *)selected {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.curPlaceInfo.y;
    coordinate.longitude = self.curPlaceInfo.x;
    
    BOOL isSelect = [selected boolValue];
    self.curMarker = [[GMSMarker alloc] init];
    _curMarker.position = coordinate;
    _curMarker.title = self.curPlaceInfo.name;
    _curMarker.snippet = self.curPlaceInfo.jibun_address;
    _curMarker.map = _gmsMapView;
    
    UIImage *img = isSelect? [UIImage imageNamed:@"icon_location_my"] : [UIImage imageNamed:@"icon_location_my_s"];
    _curMarker.icon = img;
    
    GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:17];
    [_gmsMapView animateWithCameraUpdate:move];
}

- (void)setMarker:(PlaceInfo *)placeInfo {
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = placeInfo.y;
    coordinate.longitude = placeInfo.x;
    
    UIImage *img = [UIImage imageNamed:@"icon_location_now_s"];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = img;
    marker.position = coordinate;
    marker.title = placeInfo.name;
    marker.snippet = placeInfo.jibun_address;
    marker.map = _gmsMapView;
   
    NSString *title = placeInfo.name;
    if (title == nil) {
        title = placeInfo.jibun_address;
    }
    
    marker.userData = @{@"tag" : title, @"placeInfo" : placeInfo};
    if (_arrMarker == nil) {
        self.arrMarker = [NSMutableArray array];
    }
    [_gmsMapView addObserver:self forKeyPath:@"selectedMarker" options:NSKeyValueObservingOptionNew context:0];
    
    [_arrMarker addObject:marker];
    if ([[[[_arrMarker firstObject] userData] objectForKey:@"placeInfo"] isEqual:placeInfo]) {
        GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:14];
        [_gmsMapView animateWithCameraUpdate:move];
    }
}

- (void)selectedMarker:(GMSMarker *)marker selected:(BOOL)selected {
    PlaceInfo *placeInfo = [marker.userData objectForKey:@"placeInfo"];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = placeInfo.y;
    coordinate.longitude = placeInfo.x;
    
    UIImage *img = selected? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
    marker.icon = img;
    
    if (selected) {
        GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:14];
        [_gmsMapView animateWithCameraUpdate:move];
        [_gmsMapView setSelectedMarker:marker];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:placeInfo];
    }
}
//- (void)dealloc {
//    [self.gmsMapView removeObserver:self forKeyPath:@"selectedMarker"];
//    self.gmsMapView = nil;
//}
- (void)hideAllMarker {
    for (GMSMarker *marker in _arrMarker) {
        marker.map = nil;
    }
    [_arrMarker removeAllObjects];
    [_gmsMapView clear];
    [self setCurrentMarker:[NSNumber numberWithBool:YES]];
}

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info {
    GMSMarker *selMarker = nil;
    for (GMSMarker *marker in _arrMarker) {
        [self selectedMarker:marker selected:NO];
        PlaceInfo *info1 = [marker.userData objectForKey:@"placeInfo"];
        
        if ([info1 isEqual:info]) {
            selMarker = marker;
        }
    }
    [self selectedMarker:selMarker selected:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[GMSMarker class]]) {
        GMSMarker *selMarker = [change objectForKey:NSKeyValueChangeNewKey];
        for (GMSMarker *marker in _arrMarker) {
            [self selectedMarker:marker selected:NO];
        }
        if ([selMarker isEqual:_curMarker] == NO) {
            selMarker.icon = [UIImage imageNamed:@"icon_location_now"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:[selMarker.userData objectForKey:@"placeInfo"]];
    }
}

@end
