//
//  KakaoMapView.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/20.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "KakaoMapView.h"
#import "CustomInfoView.h"
#import <DaumMap/MTMapCameraUpdate.h>

@interface KakaoMapView ()
@property (nonatomic, strong) MTMapPOIItem *curMarker;
@property (nonatomic, strong) NSMutableArray *arrMarker;
@property (nonatomic, strong) NSString *KAKAO_APP_KEY;

@end

@implementation KakaoMapView

- (void)awakeFromNib {
    [super awakeFromNib];
    _mapView.delegate = self;
    _mapView.baseMapType = MTMapTypeStandard;
}
- (void)setCurrentMarker:(NSNumber *)selected {
    
    self.curMarker = [MTMapPOIItem poiItem];
    _curMarker.itemName = self.curPlaceInfo.name;
    _curMarker.markerType = MTMapPOIItemMarkerTypeCustomImage;
    _curMarker.customImage = [UIImage imageNamed:@"icon_location_my"];
    _curMarker.markerSelectedType = MTMapPOIItemMarkerSelectedTypeCustomImage;
    _curMarker.customSelectedImage = [UIImage imageNamed:@"icon_location_my"];
    _curMarker.mapPoint = [MTMapPoint mapPointWithGeoCoord:MTMapPointGeoMake(self.curPlaceInfo.y, self.curPlaceInfo.x)];
    _curMarker.customImageAnchorPointOffset = MTMapImageOffsetMake(30,0);
    
    _curMarker.customCalloutBalloonView = [self customInfoView:self.curPlaceInfo.name];
    
    [_mapView addPOIItem:_curMarker];
    [_mapView selectPOIItem:_curMarker animated:NO];
    
    MTMapCameraUpdate *camera = [MTMapCameraUpdate move:_curMarker.mapPoint withDiameter:300];
    [_mapView animateWithCameraUpdate:camera];
}

- (void)setMarker:(PlaceInfo *)placeInfo {
    MTMapPOIItem *marker = [MTMapPOIItem poiItem];
    marker.itemName = placeInfo.name;
    marker.markerType = MTMapPOIItemMarkerTypeCustomImage;
    marker.customImage = [UIImage imageNamed:@"icon_location_now_s"];
    marker.markerSelectedType = MTMapPOIItemMarkerSelectedTypeCustomImage;
    marker.customSelectedImage = [UIImage imageNamed:@"icon_location_now"];
    marker.mapPoint = [MTMapPoint mapPointWithGeoCoord:MTMapPointGeoMake(placeInfo.y, placeInfo.x)];
    marker.customImageAnchorPointOffset = MTMapImageOffsetMake(30, 0);
    
    marker.customCalloutBalloonView = [self customInfoView:placeInfo.name];
    
    [_mapView addPOIItem:marker];
    [_mapView selectPOIItem:marker animated:NO];
    
    NSString *title = placeInfo.name;
    if (title == nil) {
        title = placeInfo.jibun_address;
    }
    marker.userObject = @{@"tag" : title, @"placeInfo" : placeInfo};
    if (_arrMarker == nil) {
        self.arrMarker = [NSMutableArray array];
    }
    
    [_arrMarker addObject:marker];
    
    if ([[(NSDictionary *)[[_arrMarker firstObject] userObject] objectForKey:@"placeInfo"] isEqual:placeInfo]) {
        MTMapCameraUpdate *camera = [MTMapCameraUpdate move:marker.mapPoint withZoomLevel:4];
        [_mapView animateWithCameraUpdate:camera];
    }
}
- (void)selectedMarker:(MTMapPOIItem *)marker selected:(BOOL)selected {
    PlaceInfo *placeInfo = [(NSDictionary*)marker.userObject objectForKey:@"placeInfo"];
    if (selected == YES) {
        [_mapView selectPOIItem:marker animated:NO];
        MTMapCameraUpdate *camera = [MTMapCameraUpdate move:marker.mapPoint withZoomLevel:4];
        [_mapView animateWithCameraUpdate:camera];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiSelectPlaceInfo object:placeInfo];
    }
}

- (void)hideAllMarker {
    for (MTMapPOIItem *marker in _arrMarker) {
        [_mapView removePOIItem:marker];
    }
    [_arrMarker removeAllObjects];
}

- (void)selectedMarkerWithPlaceInfo:(PlaceInfo *)info {
    MTMapPOIItem *selMarker = nil;
    for (MTMapPOIItem *marker in _arrMarker) {
        [self selectedMarker:marker selected:NO];
        PlaceInfo *info1 = [(NSDictionary*)marker.userObject objectForKey:@"placeInfo"];
        if ([info1 isEqual:info]) {
            selMarker = marker;
        }
    }
    [self selectedMarker:selMarker selected:YES];
}

- (UIView *)customInfoView:(NSString *)title {
    CustomInfoView *infoView = [[NSBundle mainBundle] loadNibNamed:@"CustomInfoView" owner:nil options:0].firstObject;
    infoView.lbTitle.text = title;
    
    CGSize fitSize = [infoView.lbTitle sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.heightTitle.constant = fitSize.height;
    infoView.widthTitle.constant = fitSize.width;
    [infoView setNeedsLayout];
    [infoView layoutIfNeeded];
    return infoView;
}

@end
