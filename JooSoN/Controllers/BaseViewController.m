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
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (void)showNavi{
    
    
    PlaceInfo *info = _selPlaceInfo;
    if (info == nil) {
        return;
    }
    
    NSString *url = nil;
    NSString *selMapId = AppDelegate.instance.selMapId;
    if ([selMapId isEqualToString:MapIdNaver]) {
        url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", info.y, info.x, info.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
    }
    else if ([selMapId isEqualToString:MapIdGoogle]) {
//        url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", info.jibun_address, info.y, info.x];
        url = [NSString stringWithFormat:@"comgooglemaps://?center=%lf,%lf&zoom=14", info.y, info.x];
    }
    else if ([selMapId isEqualToString:MapIdKakao]) {
//    https://map.kakao.com/link/map/우리회사,37.402056,127.108212
        url = [NSString stringWithFormat:@"https://map.kakao.com/link/map/%@,%lf,%lf", info.name, info.y, info.x];
    }
    else if ([selMapId isEqualToString:MapIdTmap]) {
//    tmap://?rGoName=[목적지명]&rGoX=[경도값]&rGoY=[위도값]
        url = [NSString stringWithFormat:@"tmap://?rGoName=%@&rGox=%lf,rGoY=%lf", info.name, info.x, info.y];
    }
    
    if (url.length > 0) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [[AppDelegate instance] openSchemeUrl:url completion:^(BOOL success) {
            if (success == NO) {
                [self.view makeToast:@"지도가 설치되어 있지 않습니다."];
            }
        }];
    }
}
@end
