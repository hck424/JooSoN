//
//  GoogleMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/15.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "GoogleMapView.h"
#import <LMGeocoder/LMGeocoder.h>
#import "InfoView.h"

@interface GoogleMapView () <GMSMapViewDelegate>
@property (nonatomic, strong) GMSMarker *curMarker;
@property (nonatomic, strong) GMSMarker *selMarker;
@property (nonatomic, strong) NSMutableArray *searchMarkers;
@property (nonatomic, strong) InfoView *infoView;
@end

@implementation GoogleMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.5666102
                                                            longitude:126.9783881
                                                                 zoom:15];
    [_gmsMapView setCamera:camera];
    self.gmsMapView.delegate = self;
    self.searchMarkers = [NSMutableArray array];
    _gmsMapView.myLocationEnabled = NO;
}

- (void)setCurrentMarker {
    if (self.curPlaceInfo) {
        UIImage *img = [UIImage imageNamed:@"icon_location_my"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = self.curPlaceInfo.y;
        coordinate.longitude = self.curPlaceInfo.x;
        
        self.curMarker = [[GMSMarker alloc] init];
        _curMarker.position = coordinate;
        _curMarker.title = self.curPlaceInfo.name;
        _curMarker.snippet = self.curPlaceInfo.jibun_address;
        _curMarker.icon = img;
        
        NSString *title = self.curPlaceInfo.name;
        if (title == nil) {
            title = self.curPlaceInfo.jibun_address;
        }
        
        _curMarker.userData = @{@"tag" : title, @"placeInfo" : self.curPlaceInfo};
        _curMarker.map = _gmsMapView;
    }
}

- (void)moveMarker:(PlaceInfo *)info zoom:(NSInteger)zoom {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = info.y;
    coordinate.longitude = info.x;
    
    GMSCameraUpdate *move = [GMSCameraUpdate setTarget:coordinate zoom:zoom];
    [_gmsMapView animateWithCameraUpdate:move];
}

- (GMSMarker *)setMarker:(PlaceInfo *)info draggable:(BOOL)draggable {
    if (info == nil) {
        return nil;
    }
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = info.y;
    coordinate.longitude = info.x;
    GMSMarker *marker = [[GMSMarker alloc] init];
    
    marker.position = coordinate;
    marker.title = info.name;
    marker.snippet = info.jibun_address;
    
    UIImage *img = [UIImage imageNamed:@"icon_location_now"];
    if (_type == MapTypeDestinate) {
        img = [UIImage imageNamed:@"icon_location_now_s"];
    }
    marker.icon = img;
    NSString *title = info.name;
    if (title == nil) {
        title = info.jibun_address;
    }
    if (title == nil) {
        title = @"";
    }
    marker.userData = @{@"tag" : title, @"placeInfo" : info};
    marker.map = _gmsMapView;
    [marker setDraggable:draggable];
    
    if (_type == MapTypeDestinate) {
        if (self.selMarker) {
            [self hideMarker:self.selMarker];
        }
        
        self.selMarker = marker;
    }
    return marker;
}

- (void)selectedMarker:(PlaceInfo *)info {
    for (GMSMarker *marker in _searchMarkers) {
        PlaceInfo *tmp = [marker.userData objectForKey:@"placeInfo"];
        if ([tmp isEqual:info]) {
            marker.icon = [UIImage imageNamed:@"icon_location_now_s"];
        }
        else {
            marker.icon = [UIImage imageNamed:@"icon_location_now"];
        }
    }
}

- (void)changeIconMarker:(GMSMarker *)marker icon:(UIImage *)icon {
    marker.icon = icon;
}

- (void)hideAllMarker {
    for (GMSMarker *marker in _searchMarkers) {
        marker.map = nil;
    }
    [_searchMarkers removeAllObjects];
    [_gmsMapView clear];
}

- (PlaceInfo *)getSelectedPlaceInfo {
    if (self.selMarker) {
        PlaceInfo *info = [self.selMarker.userData objectForKey:@"placeInfo"];
        return info;
    }
    return  nil;
}

- (void)hideMarker:(GMSMarker *)marker {
    if (marker) {
        marker.map = nil;
        marker = nil;
    }
}

#pragma mark - GMSMapViewDelegate
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if ([marker isEqual:_curMarker]) {
        marker.icon = [UIImage imageNamed:@"icon_location_my_s"];
        [_gmsMapView setSelectedMarker:marker];
    }
    else {
        
    }
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker {
    if ([marker isEqual:_curMarker]) {
        marker.icon = [UIImage imageNamed:@"icon_location_my"];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self getPlaceInfoByCoordinate:coordinate completion:^(PlaceInfo * _Nonnull placeInfo) {
        
        if (self.selMarker) {
            [self hideMarker:self.selMarker];
        }
        
        self.selMarker = [self setMarker:placeInfo draggable:YES];
        [self.gmsMapView setSelectedMarker:self.selMarker];
        
        if ([self.delegate respondsToSelector:@selector(mapViewSelectedPlaceInfo:)]) {
            [self.delegate mapViewSelectedPlaceInfo:placeInfo];
        }
    }];
}

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    UIView *infoView = nil;
//    if ([marker isEqual:self.selMarker]) {
//        if (_infoView) {
//            [_infoView removeFromSuperview];
//        }
//
//        self.infoView = [[NSBundle mainBundle] loadNibNamed:@"InfoView" owner:nil options:nil].firstObject;
////        [_infoView.btnNavi addTarget:self action:@selector(onClickedNaviAction:) forControlEvents:UIControlEventTouchUpInside];
////        [_infoView.btnNfc addTarget:self action:@selector(onClickedNfcAction:) forControlEvents:UIControlEventTouchUpInside];
//
//        PlaceInfo *info = [marker.userData objectForKey:@"placeInfo"];
//        _infoView.lbTitle.text = info.name;
//        _infoView.lbAddress.text = info.jibun_address;
//        infoView = _infoView;
//    }
//
//    return infoView;
//}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    
}
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    [self getPlaceInfoByCoordinate:marker.position completion:^(PlaceInfo * _Nonnull placeInfo) {
        if (self.selMarker) {
            [self hideMarker:self.selMarker];
        }
        [self setMarker:placeInfo draggable:YES];
        [self.gmsMapView setSelectedMarker:self.selMarker];
        if ([self.delegate respondsToSelector:@selector(mapViewSelectedPlaceInfo:)]) {
            [self.delegate mapViewSelectedPlaceInfo:placeInfo];
        }
    }];
}

@end
