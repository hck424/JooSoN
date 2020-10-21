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
#import "History+CoreDataProperties.h"
#import "JooSo+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
- (NSString *)getNaviUrlWithPalceInfo:(PlaceInfo *)info;
- (void)saveHisotryWithPlaceInfo:(PlaceInfo *)placeInfo type:(NSInteger)type;
- (void)saveHisotryWithJooso:(JooSo *)jooso type:(NSInteger)type;
- (void)saveHisotryWithHistory:(History *)history type:(NSInteger)type;
- (void)saveHisotryWithPhoneNumber:(NSString *)phoneNumber type:(NSInteger)type;
@end

NS_ASSUME_NONNULL_END
