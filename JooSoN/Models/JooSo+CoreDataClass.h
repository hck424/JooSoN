//
//  JooSo+CoreDataClass.h
//  
//
//  Created by 김학철 on 2020/01/04.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber, Thumnail;

NS_ASSUME_NONNULL_BEGIN

@interface JooSo : NSManagedObject
- (NSString *)getMainPhone;
- (NSArray *)getPhoneNumbers;
@end

NS_ASSUME_NONNULL_END

#import "JooSo+CoreDataProperties.h"
