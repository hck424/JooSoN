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
    marker.userData = @{@"tag" : title, @"placeInfo" : info};
    marker.map = _gmsMapView;
    
    [_searchMarkers addObject:marker];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[GMSMarker class]]) {
        GMSMarker *selMarker = [change objectForKey:NSKeyValueChangeNewKey];
     

        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:[selMarker.userData objectForKey:@"placeInfo"]];
    }
}

- (void)movingMarkerShow:(PlaceInfo *)placeInfo {
    if (placeInfo) {
        if (self.selMarker) {
            self.selMarker = nil;
            [self.gmsMapView clear];
        }
        
        [self setCurrentMarker];
    }
}

- (void)onClickedNaviAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(googleMapView:didClickedAction:withPlaceInfo:)]) {
        PlaceInfo *info = [self.selMarker.userData objectForKey:@"placeInfo"];
        [self.delegate googleMapView:self didClickedAction:MapCellActionNavi withPlaceInfo:info];
    }
}
- (void)onClickedNfcAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(googleMapView:didClickedAction:withPlaceInfo:)]) {
        PlaceInfo *info = [self.selMarker.userData objectForKey:@"placeInfo"];
        [self.delegate googleMapView:self didClickedAction:MapCellActionNfc withPlaceInfo:info];
    }
}

#pragma mark - GMSMapViewDelegate
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if ([marker isEqual:_curMarker]) {
        marker.icon = [UIImage imageNamed:@"icon_location_my_s"];
        [_gmsMapView setSelectedMarker:marker];
    }
    else {
        for (GMSMarker *mk in _searchMarkers) {
            UIImage *img = nil;
            if ([mk isEqual:marker]) {
                img = [UIImage imageNamed:@"icon_location_now_s"];
                [_gmsMapView setSelectedMarker:marker];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:[mk.userData objectForKey:@"placeInfo"]];
            }
            else {
                img = [UIImage imageNamed:@"icon_location_now"];
            }
            mk.icon = img;
        }
    }
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker {
    if ([marker isEqual:_curMarker]) {
        marker.icon = [UIImage imageNamed:@"icon_location_my"];
    }
}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    if ([marker isEqual:_selMarker]) {
        if ([self.delegate respondsToSelector:@selector(googleMapView:didClickedAction:withPlaceInfo:)]) {
            PlaceInfo *info = [marker.userData objectForKey:@"placeInfo"];
            [self.delegate googleMapView:self didClickedAction:MapCellActionNfc withPlaceInfo:info];
        }
    }
}
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self getPlaceInfoByCoordinate:coordinate completion:^(PlaceInfo * _Nonnull placeInfo) {
        
        
        if (self.selMarker) {
            self.selMarker.map = nil;
            self.selMarker = nil;
        }
        
        UIImage *img = [UIImage imageNamed:@"icon_location_now_s"];
        
        self.selMarker = [[GMSMarker alloc] init];
        self.selMarker.position = coordinate;
        
        self.selMarker.infoWindowAnchor = CGPointMake(0.44f, 0.0f);
//        self.selMarker.appearAnimation = kGMSMarkerAnimationPop;
        self.selMarker.icon = img;
        NSString *title = placeInfo.name;
        if (title == nil) {
            title = placeInfo.jibun_address;
        }
        self.selMarker.userData = @{@"tag" : title, @"placeInfo" : placeInfo};
        self.selMarker.map = self.gmsMapView;
    
        [self.gmsMapView setSelectedMarker:self.selMarker];
    }];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    UIView *infoView = nil;
    if ([marker isEqual:self.selMarker]) {
        if (_infoView) {
            [_infoView removeFromSuperview];
        }
        
        self.infoView = [[NSBundle mainBundle] loadNibNamed:@"InfoView" owner:nil options:nil].firstObject;
//        [_infoView.btnNavi addTarget:self action:@selector(onClickedNaviAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_infoView.btnNfc addTarget:self action:@selector(onClickedNfcAction:) forControlEvents:UIControlEventTouchUpInside];
        
        PlaceInfo *info = [marker.userData objectForKey:@"placeInfo"];
        _infoView.lbTitle.text = info.name;
        _infoView.lbAddress.text = info.jibun_address;
        infoView = _infoView;
    }
    
    return infoView;
}
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    int k = 0;
}
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    [self getPlaceInfoByCoordinate:marker.position completion:^(PlaceInfo * _Nonnull placeInfo) {
        [self movingMarkerShow:placeInfo];
    }];
}
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    
}
@end
