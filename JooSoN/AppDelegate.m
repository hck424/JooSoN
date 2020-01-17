//
//  AppDelegate.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialViewController.h"
#import "RootNavigationController.h"
#import "MainViewController.h"
#import "SceneDelegate.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "MainViewController.h"
#import <NMapsMap/NMapsMap.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface AppDelegate ()
@property (nonatomic, strong) UIView *loadingView;

@end

@implementation AppDelegate

+ (AppDelegate *)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (RootNavigationController *)rootNavigationController {
    MainViewController *mainViewController = (MainViewController *)[[UIApplication sharedApplication].keyWindow rootViewController];
    return (RootNavigationController *)mainViewController.rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [FIRApp configure];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId] length] == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:MapIdNaver forKey:SelectedMapId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NMFAuthManager shared] setClientId:NMFClientId];
    [GMSServices provideAPIKey:GoogleMapApiKey];
    [GMSPlacesClient provideAPIKey:GoogleMapApiKey];
    
    if (@available(iOS 13.0, *)) {

    }
    else {
        
        BOOL tutorialShow = [[NSUserDefaults standardUserDefaults] boolForKey:Tutorial_Once_Show];
        if (tutorialShow == NO) {
            [self callTutorialViewController];
        }
        else {
            [self callMainViewController];
        }
    }
    
    return YES;
}
- (void)callTutorialViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TutorialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
}

- (void)callMainViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    [vc setupWithType:2];
    RootNavigationController *rootNaviCon = [storyboard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
    
    vc.rootViewController = rootNaviCon;
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)startIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView == nil) {
            self.loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.loadingView.backgroundColor = RGBA(0, 0, 0, 0.2);
        }
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.loadingView];
        [self.loadingView startAnimationWithRaduis:25];
    });
}
- (void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView) {
            [self.loadingView stopAnimation];
        }
        [self.loadingView removeFromSuperview];
    });
}

- (void)openSchemeUrl:(NSString *)urlStr {
    
    if ([urlStr hasPrefix:@"tel"] || [urlStr hasPrefix:@"facetime"]) {
        
    }
    
    NSURL *phoneUrl = [NSURL URLWithString:urlStr];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:phoneUrl options:@{}
           completionHandler:^(BOOL success) {
           
        }];
    }
    else {
        [[UIApplication sharedApplication].keyWindow makeToast:@"전화번호 형식이 아닙니다." duration:1.0 position:CSToastPositionTop];
    }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"JooSoN"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
