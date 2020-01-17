//
//  Thumnail+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2019/12/31.
//
//

#import "Thumnail+CoreDataProperties.h"

@implementation Thumnail (CoreDataProperties)

+ (NSFetchRequest<Thumnail *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Thumnail"];
}

@dynamic image;
@dynamic toJooSo;

@end
