//
//  GroupName+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2020/01/02.
//
//

#import "GroupName+CoreDataProperties.h"

@implementation GroupName (CoreDataProperties)

+ (NSFetchRequest<GroupName *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"GroupName"];
}
@dynamic name;
@dynamic count;

@end
