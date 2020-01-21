//
//  NaverMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/08.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "NaverMapView.h"
#import "LMGeocoder.h"
#import "LMAddress.h"
#import "CustomInfoView.h"

@interface NaverMapView () <NMFOverlayImageDataSource>
@property (nonatomic, strong) NMFInfoWindow *infoWindow;
@property (nonatomic, strong) NMFMarker *curMarker;
@property (nonatomic, strong) NSMutableArray *arrMarker;

@end

@implementation NaverMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadData];
}

- (void)loadData {
    self.defaultCameraPosition = [NMFCameraPosition cameraPosition:NMGLatLngMake(37.5666102, 126.9783881) zoom:14 tilt:0 heading:0];
    self.map = _mapView.mapView;
    [_map moveCamera:[NMFCameraUpdate cameraUpdateWithPosition:_defaultCameraPosition]];
    
    self.infoWindow = NMFInfoWindow.infoWindow;
    _infoWindow.dataSource = self;
    _infoWindow.offsetX = -20;
    _infoWindow.offsetY = -3;
    _infoWindow.anchor = CGPointMake(0, 1);
    //        __weak typeof(_infoWindow) weakInfo = _infoWindow;
    //        _infoWindow.touchHandler = ^BOOL(NMFOverlay *__weak _Nonnull overay) {
    //            [weakInfo close];
    //            return YES;
    //        };
    _infoWindow.mapView = _map;
}

- (void)dealloc {
    self.mapView = nil;
}

- (void)hideAllMarker {
    for (NMFMarker *maker in _arrMarker) {
        maker.hidden = YES;
    }
    [_arrMarker removeAllObjects];
}
- (void)setCurrentMarker:(NSNumber *)selected {
    BOOL isSelect = [selected boolValue];
    if (_curMarker != nil) {
        _curMarker.hidden = YES;
        self.curMarker = nil;
    }
    
    UIImage *img = isSelect? [UIImage imageNamed:@"icon_location_my"] : [UIImage imageNamed:@"icon_location_my_s"];
    NMGLatLng *latLng = NMGLatLngMake(self.curPlaceInfo.y, self.curPlaceInfo.x);
    __block NMFMarker *marker = [NMFMarker markerWithPosition:latLng];
    
    NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
    marker.iconImage = overlayImg;
    
    marker.angle = 0;
    marker.iconPerspectiveEnabled = YES;
    marker.mapView = _map;
    [_map moveCamera:[NMFCameraUpdate cameraUpdateWithScrollTo:latLng] completion:nil];
    
    NSString *title = self.curPlaceInfo.name;
    if (title == nil) {
        title = self.curPlaceInfo.street;
    }
    
    marker.userInfo = @{@"tag" : title, @"placeInfo" : self.curPlaceInfo};
    __weak typeof(marker) weakMark = marker;
    __weak typeof(self) weakSelf = self;
    [marker setTouchHandler:^BOOL(NMFOverlay *__weak _Nonnull overay) {
        for (NMFMarker *marker in self.arrMarker) {
            [weakSelf selectedMarker:marker selected:NO];
        }
        [self.infoWindow openWithMarker:weakMark];
        self.infoWindow.hidden = NO;
        return YES;
    }];
    
    marker.mapView = _map;
    self.curMarker = marker;
}

- (void)setMarker:(PlaceInfo *)placeInfo {
    
    if (self.arrMarker == nil) {
        self.arrMarker = [NSMutableArray array];
    }
    
    NMGLatLng *latLng = NMGLatLngMake(placeInfo.y, placeInfo.x);
    __block NMFMarker *marker = [NMFMarker markerWithPosition:latLng];
    UIImage *img = [UIImage imageNamed:@"icon_location_now_s"];
    
    NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
    marker.iconImage = overlayImg;
    
    marker.angle = 0;
    marker.iconPerspectiveEnabled = YES;
    marker.mapView = _map;
    
    [_map moveCamera:[NMFCameraUpdate cameraUpdateWithScrollTo:latLng] completion:nil];
    
    NSString *title = placeInfo.name;
    if (title == nil) {
        title = placeInfo.jibun_address;
    }
    
    marker.userInfo = @{@"tag" : title, @"placeInfo" : placeInfo};
    __weak typeof(self) wealSelf = self;
    __weak typeof(marker) weakMark = marker;
    
    [marker setTouchHandler:^BOOL(NMFOverlay *__weak _Nonnull overay) {
        for (NMFMarker *marker in self.arrMarker) {
            [wealSelf selectedMarker:marker selected:NO];
        }
        [wealSelf selectedMarker:weakMark selected:YES];
        
        return YES;
    }];
    
    marker.mapView = _map;
    [_arrMarker addObject:marker];
}

- (void)selectedMarker:(NMFMarker *)marker selected:(BOOL)selected {
    UIImage *img = selected ? [UIImage imageNamed:@"icon_location_now"] : [UIImage imageNamed:@"icon_location_now_s"];
    NMFOverlayImage *overlayImg = [NMFOverlayImage overlayImageWithImage:img];
    marker.iconImage = overlayImg;
    if (selected) {
        self.infoWindow.hidden = NO;
        [self.infoWindow openWithMarker:marker];
        [_map moveCamera:[NMFCameraUpdate cameraUpdateWithScrollTo:marker.position] completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:[marker.userInfo objectForKey:@"placeInfo"]];
    }
    else {
        self.infoWindow.hidden = YES;
    }
}

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info {
    NMFMarker *selMarker = nil;
    for (NMFMarker *marker in _arrMarker) {
        [self selectedMarker:marker selected:NO];
        PlaceInfo *info1 = [marker.userInfo objectForKey:@"placeInfo"];
        
        if ([info1 isEqual:info]) {
            selMarker = marker;
        }
    }
    [self selectedMarker:selMarker selected:YES];
}

#pragma mark - NMFOverlayImageDataSource
- (UIView *)viewWithOverlay:(NMFOverlay *)overlay {
    CustomInfoView *infoView = [[NSBundle mainBundle] loadNibNamed:@"CustomInfoView" owner:nil options:0].firstObject;
    infoView.lbTitle.text = [_infoWindow.marker.userInfo objectForKey:@"tag"];
    
    CGSize fitSize = [infoView.lbTitle sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.heightTitle.constant = fitSize.height;
    infoView.widthTitle.constant = fitSize.width;
    [infoView setNeedsLayout];
    [infoView layoutIfNeeded];
    return infoView;
}

@end
