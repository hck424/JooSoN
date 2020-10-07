//
//  History+CoreDataProperties.h
//  
//
//  Created by 김학철 on 2020/01/15.
//
//

#import "History+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

+ (NSFetchRequest<History *> *)fetchRequest;

@property (nonatomic) int64_t callCnt;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *callState;
@property (nullable, nonatomic, copy) NSString *callType;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *phoneNumber;
@property (nonatomic) double takeCalling;
@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) double geoLat;
@property (nonatomic) double geoLng;
@property (nonatomic) int64_t historyType;

@end

NS_ASSUME_NONNULL_END
