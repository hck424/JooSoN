//
//  AppDelegate.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "RootNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)saveContext;
+ (AppDelegate *)instance;
- (RootNavigationController *)rootNavigationController;
- (void)callTutorialViewController;
- (void)callMainViewController;
- (void)startIndicator;
- (void)stopIndicator;
- (void)openSchemeUrl:(NSString *)urlStr;

@end

