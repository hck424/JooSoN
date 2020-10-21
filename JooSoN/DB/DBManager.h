//
//  DBManager.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ContactsManager.h"
#import "JooSo+CoreDataProperties.h"
#import "Thumnail+CoreDataProperties.h"
#import "PhoneNumber+CoreDataProperties.h"
#import "JooSo+CoreDataProperties.h"
#import "History+CoreDataProperties.h"
#import "GroupName+CoreDataProperties.h"
#import "MapSearchHistory+CoreDataProperties.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>


typedef void(^SUCCESS_ARR)(NSArray *arrData);
typedef void(^SUCCESS_VOID)(void);
typedef void(^SUCCESS_DIC)(NSDictionary *dataDic);
typedef void(^FAIL_ERROR)(NSError *error);

extern NSString *NMAP_ORDERBY_WEIGHT;
extern NSString *NMAP_ORDERBY_POPULARITY;
@interface DBManager : NSObject

+ (DBManager *)instance;
- (void)loadContacts:(SUCCESS_ARR)success;
- (History *)getLastHistoryOjbect;
- (BOOL)isUpdateHistoryDB:(NSDictionary *)param lastHistory:(History *)lastHistory;

- (void)uploadAllContactsToLocalDB:(NSArray *)arrData success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;

- (void)insertJooSo:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)updateJooSo:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)updateWidthJooSo:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)deleteJooSo:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)getAllJooSo:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
- (void)findJoosoWithPhoneNumber:(NSString *)phoneNumber name:(NSString *)name success:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
- (void)getGroupNameJooSoList:(NSString *)groupName success:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;

- (void)updateLike:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)getAllLike:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;

- (void)insertHistory:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)deleteHistory:(History *)history success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)getAllHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;

- (void)insertGroupName:(NSString *)groupName count:(NSInteger)count success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)getAllGroupName:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
- (void)deleteGroupName:(GroupName *)group success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)updateGroupName:(GroupName *)group success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;

- (void)getAllMapSearchHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
- (void)insertMapSearchHistory:(NSString *)text success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
- (void)deleteMapSearchHistory:(MapSearchHistory *)history success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;

//type: D: 목적지 검색, R: 주변검색
- (void)googleMapSearchPlace:(NSString *)query
                        type:(NSString *)type
                  coordinate:(CLLocationCoordinate2D)coordinate
                      circle:(NSUInteger)circle
                     success:(SUCCESS_DIC)success
                        fail:(FAIL_ERROR)fail;

- (void)reqeustDetailInfoWithPlaceId:(NSString *)placeId
                            userInfo:(id)userInfo
                             success:(SUCCESS_DIC)success
                                fail:(FAIL_ERROR)fail;
//- (NSDictionary *)requestSynchronousPlaceDetailInfo:(NSString *)placeId;
@end
