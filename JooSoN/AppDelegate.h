//
//  AppDelegate.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIViewController+LGSideMenuController.h"
#import "RootNavigationController.h"
#import "MainViewController.h"
#import "PlaceInfo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) NSString *selMapId;
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@property (nonatomic, strong) UIView *loadingView;
- (void)saveContext;
+ (AppDelegate *)instance;
- (RootNavigationController *)rootNavigationController;
- (void)callTutorialViewController;
- (void)callMainViewController;
- (void)startIndicator;
- (void)stopIndicator;
- (void)openSchemeUrl:(NSString *)urlStr;
- (void)openSchemeUrl:(NSString *)urlStr completion:(void (^)(BOOL success))completion;

@end

