//
//  CallkitController.m
//  CallkitObjectiveC
//
//  Created by Yanase Yuji on 2016/10/15.
//  Copyright © 2016年 hikaruApp. All rights reserved.
//

#import <CallKit/CXCall.h>
#import <CallKit/CXCallObserver.h>

#import "CallkitController.h"

@interface CallkitController ()<CXCallObserverDelegate>
@property ( nonatomic ) CXCallObserver *callObserver;
@end

@implementation CallkitController

NSString *const CALLING_STATE_DISCONNECTED = @"CALLING_STATE_DISCONNECTED";
NSString *const CALLING_STATE_DAILING = @"CALLING_STATE_DAILING";
NSString *const CALLING_STATE_INCOMING = @"CALLING_STATE_INCOMING";
NSString *const CALLING_STATE_CONNECTED = @"CALLING_STATE_CONNECTED";

- (instancetype)init
{
    self = [super init];
    if (self) {

        // 통화 상태 옵저버
        _callObserver = [CXCallObserver new];
        [_callObserver setDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return self;
}

// 현재 값의 취득
- (void)callstateNow {
    if ([self.callObserver.calls count] == 0) {
        [self callStateValue:nil];
    } else {
        for (CXCall *call in self.callObserver.calls) {
            [self callStateValue:call];
        }
    }
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call{
    [self callStateValue:call];
}

#pragma mark - Callkit State
- (void)callStateValue:(CXCall *)call {
    
//    NSLog(@"== hasEnded     %@", call.hasEnded? @"YES":@"NO");
//    NSLog(@"== isOutgoing   %@", call.isOutgoing? @"YES":@"NO");
//    NSLog(@"== isOnHold     %@", call.isOnHold? @"YES":@"NO");
//    NSLog(@"== hasConnected %@", call.hasConnected? @"YES":@"NO");
    
    // 중단
    if (call == nil || call.hasEnded == YES) {
        NSLog(@"CXCallState : Disconnected");
        if ([self.delegate respondsToSelector:@selector(callkitControllerState:)]) {
            [_delegate callkitControllerState:CALLING_STATE_DISCONNECTED];
        }
    }
    else if (call.isOutgoing == YES && call.hasConnected == NO) { // 발신
        NSLog(@"CXCallState :  발신");
        if ([self.delegate respondsToSelector:@selector(callkitControllerState:)]) {
            [_delegate callkitControllerState:CALLING_STATE_DAILING];
        }
    }
    else if (call.isOutgoing == NO  && call.hasConnected == NO && call.hasEnded == NO && call != nil) { // 착신
        NSLog(@"CXCallState :  착신");
        if ([self.delegate respondsToSelector:@selector(callkitControllerState:)]) {
            [_delegate callkitControllerState:CALLING_STATE_INCOMING];
        }
    }
    else if (call.hasConnected == YES && call.hasEnded == NO) { //통화중
        NSLog(@"CXCallState :  통화중");
        if ([self.delegate respondsToSelector:@selector(callkitControllerState:)]) {
            [_delegate callkitControllerState:CALLING_STATE_CONNECTED];
        }
    }
}
- (void)dealloc {
    self.callObserver = nil;
}
@end
