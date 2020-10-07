//
//  BaseViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/22.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceInfo.h"
#import "SpeechAlertView.h"
NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
- (NSString *)getNaviUrlWithPalceInfo:(PlaceInfo *)info;
- (void)saveHisotryWithType:(NSInteger)type PlaceInfo:(PlaceInfo *)placeInfo;
@end

NS_ASSUME_NONNULL_END
