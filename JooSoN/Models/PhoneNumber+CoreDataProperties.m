//
//  PhoneNumber+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2019/12/31.
//
//

#import "PhoneNumber+CoreDataProperties.h"

@implementation PhoneNumber (CoreDataProperties)

+ (NSFetchRequest<PhoneNumber *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PhoneNumber"];
}

@dynamic isMainPhone;
@dynamic label;
@dynamic number;
@dynamic toJooSo;

@end
