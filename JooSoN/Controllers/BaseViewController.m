//
//  BaseViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/22.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "DBManager.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (NSString *)getNaviUrlWithPalceInfo:(PlaceInfo *)info {
    
    if (info == nil) {
        return @"";
    }
    
    NSString *url = nil;
    NSString *selMapId = AppDelegate.instance.selMapId;
    if ([selMapId isEqualToString:MapIdNaver]) {
        url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", info.y, info.x, info.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        url = [NSString stringWithFormat:@"comgooglemaps://?center=%lf,%lf&zoom=14", info.y, info.x];
    }
    else if ([selMapId isEqualToString:MapIdKakao]) {
        url = [NSString stringWithFormat:@"kakaomap://look?p=%lf,%lf", info.y, info.x];
    }
    else if ([selMapId isEqualToString:MapIdKakaoNavi]) {
        PlaceInfo *cur = AppDelegate.instance.curPlaceInfo;
        url = [NSString stringWithFormat:@"kakaomap://route?sp=%lf,%lf&ep=%lf,%lf&by=%@", cur.y, cur.x,  info.y, info.x, info.name];
    }
    else if ([selMapId isEqualToString:MapIdTmap]) {
//    tmap://?rGoName=[목적지명]&rGoX=[경도값]&rGoY=[위도값]
        url = [NSString stringWithFormat:@"tmap://?rGoName=%@&rGox=%lf,rGoY=%lf", info.name, info.x, info.y];
    }
    if (url.length > 0) {
        return  url;
    }
    return @"";
}

- (void)saveHisotryWithType:(NSInteger)type PlaceInfo:(PlaceInfo *)placeInfo {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (placeInfo.name.length > 0) {
        [param setObject:self.selPlaceInfo.name forKey:@"name"];
    }
    [param setObject:[NSDate date] forKey:@"createDate"];
    [param setObject:[NSNumber numberWithInt:(int)type] forKey:@"historyType"];
    
    if (placeInfo.jibun_address.length > 0) {
        [param setObject:placeInfo.jibun_address forKey:@"address"];
    }
    
    if (placeInfo.x > 0 && placeInfo.y > 0) {
        [param setObject:[NSNumber numberWithDouble:self.selPlaceInfo.x] forKey:@"geoLng"];
        [param setObject:[NSNumber numberWithDouble:self.selPlaceInfo.y] forKey:@"geoLat"];
    }
    [DBManager.instance insertHistory:param success:nil fail:nil];
}

@end
