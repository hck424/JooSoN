//
//  InterfaceMain.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "InterfaceMain.h"
#import "KeychainItemWrapper.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "Utilis.h"

@interface InterfaceMain ()

@end
@implementation InterfaceMain

+ (InterfaceMain *)instance {
    static InterfaceMain *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InterfaceMain alloc] init];
    });
    return instance;
}
- (instancetype)init {
    if (self = [super init]) {
        self.contactsManager = [[ContactsManager alloc] init];
    }
    
    return self;
}

- (void)loadContacts:(SUCCESS_ARR)success {
    [_contactsManager loadContactWidthCompletionBlok:^(NSArray *dataArr) {
        
        NSArray *arrSort = nil;
        if (dataArr.count > 0) {
            
            arrSort = [dataArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                NSString *name1 = [NSString stringWithFormat:@"%@%@",  [obj1 objectForKey:@"familyName"], [obj1 objectForKey:@"givenName"]];
                
                NSString *name2 = [NSString stringWithFormat:@"%@%@", [obj2 objectForKey:@"familyName"], [obj2 objectForKey:@"givenName"]];

                name1 = [NSString stringWithFormat:@"%@%@",
                         [name1 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                         !([name1 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                         @"1", name1];

                name2 = [NSString stringWithFormat:@"%@%@",
                         [name2 localizedCaseInsensitiveCompare:@"ㄱ"]+1? @"0" :
                         !([name2 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                         @"1", name2];

                return [name1 localizedCaseInsensitiveCompare:name2];
            }];
        }
        
        if (success) {
            success(arrSort);
        }
    }];
}

- (void)uploadAllContactsToLocalDB:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    
//    NSMutableArray *arr = [NSMutableArray array];
//    if (_arrJoso.count > 0) {
//        for (JooSo *jooso in _arrJoso) {
//            NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
//
//            if ([jooso.contactIdentifierKey length] > 0) {
//                [self dictionaryToJooSo:jooso];
//                [arr addObject:itemDic];
//            }
//        }
//
//        [[DBManager instance] uploadAllContactsToLocalDB:arr success:nil fail:nil];
//    }
}

//- (NSDictionary *)dictionaryToJooSo:(JooSo *)jooso {
//    
//    NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
//    if ([jooso.contactIdentifierKey length] > 0) {
//        [itemDic setObject:jooso.contactIdentifierKey forKey:@"contactIdentifierKey"];
//    }
//    
//    jooso.address = jooso.address.length > 0 ? jooso.address : @"";
//    jooso.groupName = jooso.groupName.length > 0 ? jooso.groupName : @"";
//    jooso.callType = jooso.callType.length > 0 ? jooso.callType : @"";
//    jooso.roadAddress = jooso.roadAddress.length > 0 ? jooso.roadAddress : @"";
//    jooso.localIdentifierKey = jooso.localIdentifierKey.length > 0 ? jooso.localIdentifierKey : @"";
//    
//    [itemDic setObject:jooso.address forKey:@"address"];
//    [itemDic setObject:jooso.groupName forKey:@"groupName"];
//    [itemDic setObject:jooso.callType forKey:@"callType"];
//    if (jooso.modifyDate != nil) {
//        [itemDic setObject:jooso.modifyDate forKey:@"modifyDate"];
//    }
//    [itemDic setObject:jooso.roadAddress forKey:@"roadAddress"];
//    [itemDic setObject:jooso.localIdentifierKey forKey:@"localIdentifierKey"];
//    
//    [itemDic setObject:[NSNumber numberWithInteger:jooso.callCnt] forKey:@"callCnt"];
//    [itemDic setObject:[NSNumber numberWithInteger:jooso.takeCalling] forKey:@"takeCalling"];
//    [itemDic setObject:[NSNumber numberWithBool:jooso.takeCalling] forKey:@"likeType"];
//    [itemDic setObject:[NSNumber numberWithFloat:jooso.geoLat] forKey:@"geoLat"];
//    [itemDic setObject:[NSNumber numberWithFloat:jooso.geoLng] forKey:@"geoLng"];
//
//    return itemDic;
//}
//
//- (JooSo *)joosoToDictionary:(NSDictionary *)itemDic {
//    JooSo *jooso = [[JooSo alloc] init];
//    
//    jooso.address = [itemDic objectForKey:@"address"];
//    jooso.groupName = [itemDic objectForKey:@"groupName"];
//    jooso.callType = [itemDic objectForKey:@"callType"];
//    jooso.callCnt = [[itemDic objectForKey:@"callCnt"] integerValue];
//    jooso.takeCalling = [[itemDic objectForKey:@"takeCalling"] integerValue];
//    jooso.likeType = [[itemDic objectForKey:@"likeType"] boolValue];
//    jooso.modifyDate = [itemDic objectForKey:@"modifyDate"];
//    jooso.geoLat = [[itemDic objectForKey:@"geoLat"] floatValue];
//    jooso.geoLng = [[itemDic objectForKey:@"geoLng"] floatValue];
//    jooso.roadAddress = [itemDic objectForKey:@"roadAddress"];
//    
//    return jooso;
//}
//- (void)requestGetAllContacts:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
//    
//    [[AppDelegate instance] startIndicator];
//    [[DBManager instance] getAllContacts:^(NSArray *arrData) {
//        [[AppDelegate instance] stopIndicator];
//        if (success) {
//            for (NSDictionary *itemDic in arrData) {
//                NSString *contactIdentifierKey = [itemDic objectForKey:@"contactIdentifierKey"];
//                for (JooSo *jooso in self.arrJoso) {
//                    if ([contactIdentifierKey isEqualToString:jooso.contactIdentifierKey]) {
//                        
//                        jooso.address = [itemDic objectForKey:@"address"];
//                        jooso.groupName = [itemDic objectForKey:@"groupName"];
//                        jooso.callType = [itemDic objectForKey:@"callType"];
//                        jooso.callCnt = [[itemDic objectForKey:@"callCnt"] integerValue];
//                        jooso.takeCalling = [[itemDic objectForKey:@"takeCalling"] integerValue];
//                        jooso.likeType = [[itemDic objectForKey:@"likeType"] boolValue];
//                        jooso.modifyDate = [itemDic objectForKey:@"modifyDate"];
//                        jooso.geoLat = [[itemDic objectForKey:@"geoLat"] floatValue];
//                        jooso.geoLng = [[itemDic objectForKey:@"geoLng"] floatValue];
//                        jooso.roadAddress = [itemDic objectForKey:@"roadAddress"];
//                    }
//                }
//            }
//            success(self.arrJoso);
//            
//        }
//    } fail:^(NSError *error) {
//        [[AppDelegate instance] stopIndicator];
//        if (fail) {
//            fail(error);
//        }
//        
//    }];
//}
//
//- (void)requestGroupList:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
//    NSMutableArray *arrTmp = [NSMutableArray array];
//    for (JooSo *jooso in _arrJoso) {
//        if ([jooso.organizationName length] > 0) {
//            [arrTmp addObject:jooso];
//        }
//    }
//    
//    NSArray *arrSort = [arrTmp sortedArrayUsingComparator:^NSComparisonResult(JooSo *obj1, JooSo *obj2) {
//        NSString *name1 = obj1.organizationName;
//        NSString *name2 = obj2.organizationName;
//        
//        name1 = [NSString stringWithFormat:@"%@%@",
//                 [name1 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
//                 !([name1 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
//                 @"1", name1];
//        
//        name2 = [NSString stringWithFormat:@"%@%@",
//                 [name2 localizedCaseInsensitiveCompare:@"ㄱ"]+1? @"0" :
//                 !([name2 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
//                 @"1", name2];
//        
//        return [name1 localizedCaseInsensitiveCompare:name2];
//    }] ;
//    
//    if (success) {
//        success(arrSort);
//    }
//    
//}
//- (BOOL)isUpdatableHistory {
//    return NO;
//}
//
//- (void)requestInsertHistory:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
//    NSDictionary *dic = [self dictionaryToJooSo:jooso];
//    [[DBManager instance] insertHistory:dic success:^{
//        if (success){
//            success();
//        }
//    } fail:^(NSError *error) {
//        if (fail) {
//            fail(error);
//        }
//    }];
//}
//
//- (void)requestUpdateHistory:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
//    
//}
//- (void)requestGetAllHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
//    [[AppDelegate instance] startIndicator];
//    [[DBManager instance] getAllHistory:^(NSArray *arrData) {
//        [[AppDelegate instance] stopIndicator];
//        NSMutableArray *arr = [NSMutableArray array];
//        
//        for (NSDictionary *itemDic in arrData) {
//            NSString *contactIdentifierKey = [itemDic objectForKey:@"contactIdentifierKey"];
//            JooSo *jooso = [[JooSo alloc] init];
//            JooSo *findJooso = nil;
//            
//            for (JooSo *js in self.arrJoso) {
//                if ([contactIdentifierKey isEqualToString:js.contactIdentifierKey]) {
//                    findJooso = js;
//                    break;
//                }
//            }
//            
//            jooso.phoneNumber = findJooso.phoneNumber;
//            jooso.phoneNumbers = findJooso.phoneNumbers;
//            jooso.familyName = findJooso.familyName;
//            jooso.givenName = findJooso.givenName;
//            jooso.organizationName = findJooso.organizationName;
//            jooso.departmentName = findJooso.departmentName;
//            jooso.jobTitle = findJooso.jobTitle;
//            jooso.thumnail = findJooso.thumnail;
//            jooso.contactIdentifierKey = [itemDic objectForKey:@"contactIdentifierKey"];
//            jooso.localIdentifierKey = [itemDic objectForKey:@"localIdentifierKey"];
//            
//            jooso.address = [itemDic objectForKey:@"address"];
//            jooso.groupName = [itemDic objectForKey:@"groupName"];
//            jooso.callType = [itemDic objectForKey:@"callType"];
//            jooso.callCnt = [[itemDic objectForKey:@"callCnt"] integerValue];
//            jooso.takeCalling = [[itemDic objectForKey:@"takeCalling"] integerValue];
//            jooso.likeType = [[itemDic objectForKey:@"likeType"] boolValue];
//            jooso.modifyDate = [itemDic objectForKey:@"modifyDate"];
//            jooso.geoLat = [[itemDic objectForKey:@"geoLat"] floatValue];
//            jooso.geoLng = [[itemDic objectForKey:@"geoLng"] floatValue];
//            jooso.roadAddress = [itemDic objectForKey:@"roadAddress"];
//
//            [arr addObject:jooso];
//        }
//        
//        if (success) {
//            success(arr);
//        }
//    } fail:^(NSError *error) {
//        [[AppDelegate instance] stopIndicator];
//        if (fail) {
//            fail(error);
//        }
//    }];
//}
@end
