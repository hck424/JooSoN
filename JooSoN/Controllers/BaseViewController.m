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
        url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", info.x, info.y, info.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
        //네이버 네비
//    nmap://route/car?slat=37.4640070&slng=126.9522394&sname=%EC%84%9C%EC%9A%B8%EB%8C%80%ED%95%99%EA%B5%90&dlat=37.5209436&dlng=127.1230074&dname=%EC%98%AC%EB%A6%BC%ED%94%BD%EA%B3%B5%EC%9B%90&appname=com.example.myapp
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
        url = [NSString stringWithFormat:@"comgooglemaps://?center=%lf,%lf&zoom=14", info.x, info.y];
    }
    else if ([selMapId isEqualToString:MapIdKakao]) {
        url = [NSString stringWithFormat:@"kakaomap://look?p=%lf,%lf", info.x, info.y];
    }
    else if ([selMapId isEqualToString:MapIdKakaoNavi]) {
        PlaceInfo *cur = AppDelegate.instance.curPlaceInfo;
        url = [NSString stringWithFormat:@"kakaomap://route?sp=%lf,%lf&ep=%lf,%lf&by=%@", cur.x, cur.y,  info.x, info.y, info.name];
    }
    else if ([selMapId isEqualToString:MapIdTmap]) {
        url = [NSString stringWithFormat:@"tmap://?rGoName=%@&rGox=%lf,rGoY=%lf", info.name, info.x, info.y];
    }
    if (url.length > 0) {
        return  url;
    }
    return @"";
}
//        historytype =? 0: 전화타입, 1: sms, 2: facephone, 3: nfc, 4: navi
- (void)saveHisotryWithPlaceInfo:(PlaceInfo *)placeInfo type:(NSInteger)type {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (placeInfo.name.length > 0) {
        [param setObject:placeInfo.name forKey:@"name"];
    }
    [param setObject:[NSDate date] forKey:@"createDate"];
    [param setObject:[NSNumber numberWithInteger:type] forKey:@"historyType"];
    
    if (placeInfo.jibun_address.length > 0) {
        [param setObject:placeInfo.jibun_address forKey:@"address"];
    }
    
    if (placeInfo.x > 0 && placeInfo.y > 0) {
        [param setObject:[NSNumber numberWithDouble:placeInfo.x] forKey:@"geoLat"];
        [param setObject:[NSNumber numberWithDouble:placeInfo.y] forKey:@"geoLng"];
    }
    [DBManager.instance insertHistory:param success:nil fail:nil];
}

- (void)saveHisotryWithJooso:(JooSo *)jooso type:(NSInteger)type {
    NSMutableDictionary *param = nil;
    if (jooso != nil) {
        param = [NSMutableDictionary dictionary];
        
        [param setObject:jooso.name forKey:@"name"];
        [param setObject:[jooso getMainPhone]  forKey:@"phoneNumber"];
        [param setObject:@"0" forKey:@"callType"];
        [param setObject:[NSDate date] forKey:@"createDate"];
        [param setObject:[NSNumber numberWithInteger:type] forKey:@"historyType"];
        
        if (jooso.address != nil && jooso.geoLng > 0 && jooso.geoLat > 0) {
            [param setObject:jooso.address forKeyedSubscript:@"address"];
            [param setObject:[NSNumber numberWithDouble:jooso.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:jooso.geoLng] forKey:@"geoLng"];
        }
        
        [DBManager.instance insertHistory:param success:nil fail:nil];
    }
}

- (void)saveHisotryWithHistory:(History *)history type:(NSInteger)type {
    if (history != nil) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        if (history.name.length > 0) {
            [param setObject:history.name forKey:@"name"];
        }
        else if (history.phoneNumber.length > 0) {
            [param setObject:history.phoneNumber  forKey:@"phoneNumber"];
        }
        
        [param setObject:[NSDate date] forKey:@"createDate"];
        [param setObject:[NSNumber numberWithInteger:type] forKey:@"historyType"];
        
        if (history.address != nil && history.geoLng > 0 && history.geoLat > 0) {
            [param setObject:history.address forKeyedSubscript:@"address"];
            [param setObject:[NSNumber numberWithDouble:history.geoLat] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithDouble:history.geoLng] forKey:@"geoLng"];
        }
        
        [DBManager.instance insertHistory:param success:nil fail:nil];
    }
}
- (void)saveHisotryWithPhoneNumber:(NSString *)phoneNumber type:(NSInteger)type {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    [param setObject:phoneNumber  forKey:@"phoneNumber"];
    [param setObject:[NSDate date] forKey:@"createDate"];
    [param setObject:[NSNumber numberWithInteger:type] forKey:@"historyType"];
    
    [DBManager.instance insertHistory:param success:nil fail:nil];
}
@end
