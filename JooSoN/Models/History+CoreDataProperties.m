//
//  History+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2020/01/15.
//
//

#import "History+CoreDataProperties.h"

@implementation History (CoreDataProperties)

+ (NSFetchRequest<History *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"History"];
}

@dynamic callCnt;
@dynamic createDate;
@dynamic callState;
@dynamic callType;
@dynamic name;
@dynamic phoneNumber;
@dynamic takeCalling;
@dynamic address;
@dynamic geoLat;
@dynamic geoLng;
@dynamic historyType;
@end
