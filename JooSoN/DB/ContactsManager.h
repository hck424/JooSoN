//
//  ContactsManager.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const JooSoPhoneLabelMobile;
extern NSString *const JooSoPhoneLabelHome;
extern NSString *const JooSoPhoneLabelWork;
extern NSString *const JooSoPhoneLabelSchool;
extern NSString *const JooSoPhoneLabeliPhone;
extern NSString *const JooSoPhoneLabelMain;
extern NSString *const JooSoPhoneLabelHomeFAX;
extern NSString *const JooSoPhoneLabelWorkFAX;
extern NSString *const JooSoPhoneLabelPager;
extern NSString *const JooSoPhoneLabelOther;

@interface ContactsManager : NSObject
- (void)loadContactWidthCompletionBlok:(void (^)(NSArray *dataArr))completion;
- (void)insertAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion;
- (void)deleteAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion;
@end
