//
//  JooSo+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2020/01/04.
//
//

#import "JooSo+CoreDataProperties.h"

@implementation JooSo (CoreDataProperties)

+ (NSFetchRequest<JooSo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"JooSo"];
}

@dynamic address;
@dynamic contactIdentifier;
@dynamic departmentName;
@dynamic emailAddresses;
@dynamic geoLat;
@dynamic geoLng;
@dynamic name;
@dynamic groupName;
@dynamic jobTitle;
@dynamic like;
@dynamic localIdentifier;
@dynamic organizationName;
@dynamic roadAddress;
@dynamic toPhoneNumber;
@dynamic toThumnail;
@dynamic placeName;

@end
