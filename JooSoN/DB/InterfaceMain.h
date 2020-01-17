//
//  InterfaceMain.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsManager.h"


typedef void(^SUCCESS_ARR)(NSArray *arrData);
typedef void(^SUCCESS_VOID)(void);
typedef void(^SUCCESS_DIC)(NSDictionary *dataDic);
typedef void(^FAIL_ERROR)(NSError *error);

@interface InterfaceMain : NSObject
@property (nonatomic, strong) ContactsManager *contactsManager;
+ (InterfaceMain *)instance;
- (BOOL)isUpdatableHistory;

- (void)loadContacts:(SUCCESS_ARR)success;

- (void)uploadAllContactsToLocalDB:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;

//- (void)requestGetAllContacts:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
//- (void)requestGroupList:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
//- (void)requestInsertHistory:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
//- (void)requestUpdateHistory:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail;
//- (void)requestGetAllHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail;
@end

