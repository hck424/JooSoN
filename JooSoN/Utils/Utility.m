//
//  Utility.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "Utility.h"
#import "KeychainItemWrapper.h"

@implementation Utility
//처음에 UUID를 KeyChain에서 불러오는데 nil이라면 UUID를 생성해서 KeyChain에 저장한다.
//저장 후에 다시 함수를 호출 하면 저장된 값을 리턴한다.
+ (NSString*)getUUID {
    
    // initialize keychaing item for saving UUID.
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"JOOSON_UUID" accessGroup:nil];
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    if(uuid == nil || uuid.length == 0) {
        
        // if there is not UUID in keychain, make UUID and save it.
        
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        
        CFRelease(uuidRef);
        
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        
        CFRelease(uuidStringRef);
        
        // save UUID in keychain
        
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
        
    }
    return uuid;
}

+ (BOOL)isIphoneX {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edge = [[UIApplication sharedApplication].keyWindow safeAreaInsets];
        if (edge.bottom > 0) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}
//yyyy-MM-DD HH:MM:ss
+ (NSString *)stringDateToDate:(NSDate *)date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [df stringFromDate:date];
}

+ (NSString *)createLocalIdentifier {
    NSString *str = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970] * 1000];
    return [[str componentsSeparatedByString:@"."] firstObject];
}

@end
