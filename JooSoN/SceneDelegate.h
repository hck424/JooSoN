//
//  SceneDelegate.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;
+ (SceneDelegate *)instance;
- (void)callMainViewController;
- (void)callTutorialViewController;

@end

