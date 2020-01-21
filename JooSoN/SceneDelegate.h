//
//  SceneDelegate.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "RootNavigationController.h"

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (SceneDelegate *)instance;
- (RootNavigationController *)rootNavigationController;
- (void)callTutorialViewController;
- (void)callMainViewController;
- (void)startIndicator;
- (void)stopIndicator;
- (void)openSchemeUrl:(NSString *)urlStr;

@end

