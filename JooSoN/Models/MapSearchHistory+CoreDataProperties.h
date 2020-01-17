//
//  MapSearchHistory+CoreDataProperties.h
//  
//
//  Created by 김학철 on 2020/01/07.
//
//

#import "MapSearchHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MapSearchHistory (CoreDataProperties)

+ (NSFetchRequest<MapSearchHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSDate *date;

@end

NS_ASSUME_NONNULL_END
