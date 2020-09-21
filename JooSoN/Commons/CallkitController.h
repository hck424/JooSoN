//
//  CallkitController.h
//  CallkitObjectiveC
//
//  Created by Yanase Yuji on 2016/10/15.
//  Copyright © 2016年 hikaruApp. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const CALLING_STATE_DISCONNECTED;
extern NSString *const CALLING_STATE_DAILING;
extern NSString *const CALLING_STATE_INCOMING;
extern NSString *const CALLING_STATE_CONNECTED;

@protocol CallkitControllerDelegate <NSObject>
- (void)callkitControllerState:(NSString *)state;
@end

@interface CallkitController : NSObject
@property (nonatomic, weak) id <CallkitControllerDelegate>delegate;
- (void)callstateNow;

@end
