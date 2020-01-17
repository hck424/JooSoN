//
//  PhoneNumber+CoreDataProperties.h
//  
//
//  Created by 김학철 on 2019/12/31.
//
//

#import "PhoneNumber+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PhoneNumber (CoreDataProperties)

+ (NSFetchRequest<PhoneNumber *> *)fetchRequest;

@property (nonatomic) BOOL isMainPhone;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSString *number;
@property (nullable, nonatomic, retain) JooSo *toJooSo;

@end

NS_ASSUME_NONNULL_END
