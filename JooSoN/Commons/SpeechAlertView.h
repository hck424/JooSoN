//
//  SpeechAlertView.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/22.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SpeechAlertView : UIView
+ (void)showWithTitle:(NSString *)title
           completion:(void (^)(NSString *result))completion;
@end

NS_ASSUME_NONNULL_END
