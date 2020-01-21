//
//  JooSo+CoreDataProperties.h
//  
//
//  Created by 김학철 on 2020/01/04.
//
//

#import "JooSo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface JooSo (CoreDataProperties)

+ (NSFetchRequest<JooSo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *contactIdentifier;
@property (nullable, nonatomic, copy) NSString *departmentName;
@property (nullable, nonatomic, copy) NSString *emailAddresses;
@property (nonatomic) double geoLat;
@property (nonatomic) double geoLng;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *groupName;
@property (nullable, nonatomic, copy) NSString *jobTitle;
@property (nonatomic) BOOL like;
@property (nullable, nonatomic, copy) NSString *localIdentifier;
@property (nullable, nonatomic, copy) NSString *organizationName;
@property (nullable, nonatomic, copy) NSString *roadAddress;
@property (nullable, nonatomic, copy) NSString *placeName;
@property (nullable, nonatomic, retain) NSOrderedSet<PhoneNumber *> *toPhoneNumber;
@property (nullable, nonatomic, retain) Thumnail *toThumnail;

@end

@interface JooSo (CoreDataGeneratedAccessors)

- (void)insertObject:(PhoneNumber *)value inToPhoneNumberAtIndex:(NSUInteger)idx;
- (void)removeObjectFromToPhoneNumberAtIndex:(NSUInteger)idx;
- (void)insertToPhoneNumber:(NSArray<PhoneNumber *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeToPhoneNumberAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInToPhoneNumberAtIndex:(NSUInteger)idx withObject:(PhoneNumber *)value;
- (void)replaceToPhoneNumberAtIndexes:(NSIndexSet *)indexes withToPhoneNumber:(NSArray<PhoneNumber *> *)values;
- (void)addToPhoneNumberObject:(PhoneNumber *)value;
- (void)removeToPhoneNumberObject:(PhoneNumber *)value;
- (void)addToPhoneNumber:(NSOrderedSet<PhoneNumber *> *)values;
- (void)removeToPhoneNumber:(NSOrderedSet<PhoneNumber *> *)values;

@end

NS_ASSUME_NONNULL_END
