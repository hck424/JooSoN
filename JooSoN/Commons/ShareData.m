//
//  ShareData.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "ShareData.h"

@implementation ShareData
+ (ShareData *)instance {
    static ShareData *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ShareData alloc] init];
    });
    return instance;
}

@end
