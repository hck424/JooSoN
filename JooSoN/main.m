//
//  main.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void uncaughtException(NSException *exception) {
    NSLog(@"exception : %@", [exception callStackSymbols]);
}

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    NSSetUncaughtExceptionHandler(uncaughtException);
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
