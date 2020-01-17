//
//  GroupName+CoreDataProperties.h
//  
//
//  Created by 김학철 on 2020/01/02.
//
//

#import "GroupName+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GroupName (CoreDataProperties)

+ (NSFetchRequest<GroupName *> *)fetchRequest;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t count;
@end

NS_ASSUME_NONNULL_END
