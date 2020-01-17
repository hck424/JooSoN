//
//  JooSo+CoreDataClass.m
//  
//
//  Created by 김학철 on 2020/01/04.
//
//

#import "JooSo+CoreDataClass.h"

@implementation JooSo
- (NSString *)getMainPhone {
    
    NSString *mainPhoneNumber = nil;
    for (PhoneNumber *phone in self.toPhoneNumber) {
        NSString *number = [(NSManagedObject *)phone valueForKey:@"number"];
        BOOL isMainPhone = [[(NSManagedObject *)phone valueForKey:@"isMainPhone"] boolValue];
        if (isMainPhone) {
            mainPhoneNumber = number;
            break;
        }
    }
    
    if (mainPhoneNumber.length == 0) {
        PhoneNumber *phone = [self.toPhoneNumber firstObject];
        NSString *number = (NSString *)[(NSManagedObject *)phone valueForKey:@"number"];
        mainPhoneNumber = number;
    }
    
    return mainPhoneNumber;
}
- (NSArray *)getPhoneNumbers {
    NSMutableArray *arr = [NSMutableArray array];
    
    for (PhoneNumber *phone in self.toPhoneNumber) {
        NSString *number = [(NSManagedObject *)phone valueForKey:@"number"];
        if (number.length > 0) {
            [arr addObject:number];
        }
    }
    
    return arr;
}

@end
