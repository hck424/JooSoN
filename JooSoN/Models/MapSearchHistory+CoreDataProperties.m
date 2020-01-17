//
//  MapSearchHistory+CoreDataProperties.m
//  
//
//  Created by 김학철 on 2020/01/07.
//
//

#import "MapSearchHistory+CoreDataProperties.h"

@implementation MapSearchHistory (CoreDataProperties)

+ (NSFetchRequest<MapSearchHistory *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MapSearchHistory"];
}

@dynamic text;
@dynamic date;

@end
