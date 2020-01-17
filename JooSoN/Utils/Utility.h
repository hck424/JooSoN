//
//  Utility.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+ (NSString*)getUUID;
+ (BOOL)isIphoneX;
+ (NSString *)stringDateToDate:(NSDate *)date;
+ (NSString *)createLocalIdentifier;
@end
