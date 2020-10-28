//
//  ContactsManager.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "ContactsManager.h"
#import <Contacts/Contacts.h>
#import "NSString+Utility.h"
#import "NSObject+Utility.h"

NSString *const JooSoPhoneLabelMobile = @"휴대폰";
NSString *const JooSoPhoneLabelHome = @"집";
NSString *const JooSoPhoneLabelWork = @"직장";
NSString *const JooSoPhoneLabelSchool = @"학교";
NSString *const JooSoPhoneLabelHomeFAX = @"집팩스";
NSString *const JooSoPhoneLabelWorkFAX = @"직장팩스";
NSString *const JooSoPhoneLabelPager = @"호출기";
NSString *const JooSoPhoneLabelOther = @"기타";

@implementation ContactsManager
- (void)loadContactWidthCompletionBlok:(void (^)(NSArray *dataArr))completion {
    if ([CNContactStore class]) {
        //ios9 or later
        CNEntityType entityType = CNEntityTypeContacts;
        if([CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    [self getAllContact:completion];
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
        {
            [self getAllContact:completion];
        }
    }
}

- (void)getAllContact:(void (^)(NSArray *dataArr))completion {
    if([CNContactStore class]) {
        //iOS 9 or later
        NSError* contactError;
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];

        NSArray *keysToFetch =@[CNContactIdentifierKey,
                                 CNContactFamilyNameKey,
                                 CNContactGivenNameKey,
                                 CNContactJobTitleKey,
                                 CNContactDepartmentNameKey,
                                 CNContactOrganizationNameKey,
                                 CNContactPhoneNumbersKey,
                                 CNContactEmailAddressesKey,
                                 CNContactPostalAddressesKey,
                                 CNContactImageDataKey];

        CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        __block NSMutableArray *arrResult = [NSMutableArray array];
        BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [arrResult addObject:[self parseContactWithContact:contact]];
        }];
        if (success) {
            completion(arrResult);
        }
    }
}

- (NSString *)cnLabelPhoneNumberLabelToLocalLabel:(NSString *)label {

//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberiPhone                NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberMobile                NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberMain                  NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberHomeFax               NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberWorkFax               NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberOtherFax              NS_AVAILABLE(10_11, 9_0);
//    CONTACTS_EXTERN NSString * const CNLabelPhoneNumberPager                 NS_AVAILABLE(10_11, 9_0);

    
    if ([label isEqualToString:JooSoPhoneLabelHome]) {
        return label;
    }
    else if ([label isEqualToString:JooSoPhoneLabelMobile]) {
        return CNLabelPhoneNumberMobile;
    }
    else if ([label isEqualToString:JooSoPhoneLabelWork]) {
        return label;
    }
    else if ([label isEqualToString:JooSoPhoneLabelSchool]) {
        return label;
    }
    else if ([label isEqualToString:JooSoPhoneLabelHomeFAX]) {
        return CNLabelPhoneNumberHomeFax;
    }
    else if ([label isEqualToString:JooSoPhoneLabelWorkFAX]) {
        return CNLabelPhoneNumberWorkFax;
    }
    else if ([label isEqualToString:JooSoPhoneLabelPager]) {
        return CNLabelPhoneNumberPager;
    }
    else if ([label isEqualToString:JooSoPhoneLabelOther]) {
        return label;
    }
    return @"";
}

- (NSMutableDictionary *)parseContactWithContact :(CNContact* )contact {
    
    NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
    
    NSString *contactIdentifier = [contact.identifier isNotEmpty]? contact.identifier : @"";
    NSString *organizationName = [contact.organizationName isNotEmpty]? contact.organizationName : @"";
    NSString *departmentName = [contact.departmentName isNotEmpty]? contact.departmentName : @"";
    NSString *jobTitle = [contact.jobTitle isNotEmpty]? contact.jobTitle : @"";
    

    [itemDic setObject:contactIdentifier forKey:@"contactIdentifier"];
    
    NSMutableString *name = [NSMutableString string];
    if ([contact.familyName isNotEmpty]) {
        [name setString:contact.familyName];
    }
    if ([contact.givenName isNotEmpty]) {
        [name appendString:contact.givenName];
    }
    
    [itemDic setObject:name forKey:@"name"];
    [itemDic setObject:organizationName forKey:@"organizationName"];
    [itemDic setObject:departmentName forKey:@"departmentName"];
    [itemDic setObject:jobTitle forKey:@"jobTitle"];
    
    NSMutableArray *phoneNumbers = [NSMutableArray array];

    NSInteger i = 0;
    
    for (CNLabeledValue *cnLabel in contact.phoneNumbers) {
        CNPhoneNumber *cnPhone = cnLabel.value;
        if (cnPhone.stringValue) {
            NSString *label = cnLabel.label;
            label = [label stringByReplacingOccurrencesOfString:@"_" withString:@""];
            label = [label stringByReplacingOccurrencesOfString:@"$" withString:@""];
            label = [label stringByReplacingOccurrencesOfString:@"!" withString:@""];
            label = [label stringByReplacingOccurrencesOfString:@"<" withString:@""];
            label = [label stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            label = label? label : @"";
            if ([label isEqualToString:@"Mobile"]) {
                label = JooSoPhoneLabelMobile;
            }
            else if ([label isEqualToString:@"Home"]) {
                label = JooSoPhoneLabelHome;
            }
            else if ([label isEqualToString:@"Work"]) {
                label = JooSoPhoneLabelWork;
            }
            else if ([label isEqualToString:@"School"]) {
                label = JooSoPhoneLabelSchool;
            }
            else if ([label isEqualToString:@"HomeFAX"]) {
                label = JooSoPhoneLabelHomeFAX;
            }
            else if ([label isEqualToString:@"WorkFAX"]) {
                label = JooSoPhoneLabelWorkFAX;
            }
            else if ([label isEqualToString:@"Pager"]) {
                label = JooSoPhoneLabelPager;
            }
            else if ([label isEqualToString:@"Other"]) {
                label = JooSoPhoneLabelOther;
            }
            else {
                label = JooSoPhoneLabelMobile;
            }
            
            NSString *phoneNumber = cnPhone.stringValue ? cnPhone.stringValue : @"";
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [phoneNumbers addObject:dic];
            [dic setObject:label forKey:@"label"];
            [dic setObject:phoneNumber forKey:@"number"];
            
            if (i == 0) {
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isMainPhone"];
            }
            else {
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isMainPhone"];
            }
            
            i++;
        }
    }
    
    [itemDic setObject:phoneNumbers forKey:@"phoneNumbers"];
    
    NSString *emailAddresses = @"";
    for (CNLabeledValue *cnValue in contact.emailAddresses) {
        emailAddresses = [cnValue valueForKey:@"value"];
        break;
    }
    [itemDic setObject:emailAddresses forKey:@"emailAddresses"];
    
    
    if (contact.imageData != nil) {
        UIImage *thumnail = [UIImage imageWithData:contact.imageData];
        [itemDic setObject:thumnail forKey:@"thumnail"];
    }

    //주소 setting
    NSMutableArray *addrArr = [[NSMutableArray alloc] init];
    CNPostalAddressFormatter * formatter = [[CNPostalAddressFormatter alloc] init];
    NSArray *addresses = (NSArray*)[contact.postalAddresses valueForKey:@"value"];
    if (addresses.count > 0) {
        for (CNPostalAddress* address in addresses) {
            [addrArr addObject:[formatter stringFromPostalAddress:address]];
            break ;
        }
    }

    NSString *tmpStr = [addrArr firstObject];
    NSArray *tmpArr = [tmpStr componentsSeparatedByString:@"\n"];
    NSMutableString *addStr = [NSMutableString string];

    for (int i = 0; i < tmpArr.count; i++) {
        if (i == tmpArr.count - 1) {
            [addStr appendString:[NSString stringWithFormat:@" %@", [tmpArr objectAtIndex:i]]];
        }
        else {
            [addStr appendString:[NSString stringWithFormat:@"%@ ", [tmpArr objectAtIndex:i]]];
        }
    }
    
    [itemDic setObject:addStr forKey:@"address"];
    
    return itemDic;
}

////FIXME:: insert
- (void)insertAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *name = [param objectForKey:@"name"];
    NSString *address = [param objectForKey:@"address"];
    
    NSString *departmentName = [param objectForKey:@"departmentName"];
    NSString *emailAddresses = [param objectForKey:@"emailAddresses"];
    
    double geoLat = [[param objectForKey:@"geoLat"] doubleValue];
    double geoLng = [[param objectForKey:@"geoLng"] doubleValue];
    
    NSString *groupName = [param objectForKey:@"groupName"];
    NSString *jobTitle = [param objectForKey:@"jobTitle"];
    BOOL like = [[param objectForKey:@"like"] boolValue];
    
    NSString *organizationName = [param objectForKey:@"organizationName"];
    NSString *roadAddress = [param objectForKey:@"roadAddress"];
    
    NSArray *phoneNumbers = [param objectForKey:@"phoneNumbers"];
    UIImage *thumnail = [param objectForKey:@"thumnail"];
    
    address = address ? address : @"";
    departmentName = departmentName ? departmentName : @"";
    emailAddresses = emailAddresses ? emailAddresses : @"";
    
    groupName = groupName ? groupName : @"";
    jobTitle = jobTitle ? jobTitle : @"";
    like = like;
    organizationName = organizationName ? organizationName : @"";
    roadAddress = roadAddress ? roadAddress : @"";
    
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    contact.givenName = name;
    
    if (emailAddresses.length > 0) {
        CNLabeledValue *homeEmail = [[CNLabeledValue alloc] init];
        [homeEmail setValue:emailAddresses forKey:CNLabelHome];
        contact.emailAddresses = @[homeEmail];
    }
    
    NSMutableArray *arrPhone = [NSMutableArray array];
    for (NSDictionary *itemDic in phoneNumbers) {
        NSString *label = [itemDic objectForKey:@"label"];
        NSString *number = [itemDic objectForKey:@"number"];
        CNPhoneNumber *cnNumber = [CNPhoneNumber phoneNumberWithStringValue:number];
        NSString *cnlabel = [self cnLabelPhoneNumberLabelToLocalLabel:label];
        CNLabeledValue *labelValue = [[CNLabeledValue alloc] initWithLabel:cnlabel value:cnNumber];

        [arrPhone addObject:labelValue];
    }
    
    if (arrPhone.count > 0) {
        contact.phoneNumbers = arrPhone;
    }

    if (address.length > 0) {
        CNMutablePostalAddress *homeAddress = [[CNMutablePostalAddress alloc] init];
        NSArray *arrAddress = [address componentsSeparatedByString:@" "];

        NSString *state = nil;
        NSString *city = nil;
        NSMutableString *street = [NSMutableString string];
        NSString *subAdministrativeArea = nil;
        for (int i = 0; i < arrAddress.count; i++ ) {
            if ( i== 0) {
                state = [arrAddress objectAtIndex:i];
            }
            else if (i == 1) {
                city = [arrAddress objectAtIndex:i];
            }
            else if (i == 2) {
                [street setString:[arrAddress objectAtIndex:i]];
            }
            else if (i == 3 || i == 4) {
                [street appendString:[NSString stringWithFormat:@" %@",[arrAddress objectAtIndex:i]]];
            }

        }
        
        homeAddress.state = state;
        homeAddress.city = city;
        homeAddress.street = street;

        if (geoLat > 0 || geoLng > 0) {
            subAdministrativeArea = [NSString stringWithFormat:@"%lf|%lf",geoLat, geoLng];
            homeAddress.subAdministrativeArea = subAdministrativeArea;
        }
        contact.postalAddresses = @[[[CNLabeledValue alloc] initWithLabel:CNLabelHome value:homeAddress]];
    }
    
    if (thumnail != nil) {
        NSData *imgData = UIImagePNGRepresentation(thumnail);
        contact.imageData = imgData;
    }

    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveReq = [[CNSaveRequest alloc] init];

    NSError *errror = nil;
    @try {
        [saveReq addContact:contact toContainerWithIdentifier:nil];
        [store executeSaveRequest:saveReq error:&errror];
        
        if (completion) {
            completion ((errror == nil), errror);
        }
    }
    @catch (NSException *e) {
        if (completion) {
            completion (NO, nil);
        }
    }
}

- (void)updateAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion {

    NSString *name = [param objectForKey:@"name"];
    NSString *address = [param objectForKey:@"address"];
    
    NSString *departmentName = [param objectForKey:@"departmentName"];
    NSString *emailAddresses = [param objectForKey:@"emailAddresses"];
    
    double geoLat = [[param objectForKey:@"geoLat"] doubleValue];
    double geoLng = [[param objectForKey:@"geoLng"] doubleValue];
    
    NSString *groupName = [param objectForKey:@"groupName"];
    NSString *jobTitle = [param objectForKey:@"jobTitle"];
    BOOL like = [[param objectForKey:@"like"] boolValue];
    
    NSString *organizationName = [param objectForKey:@"organizationName"];
    NSString *roadAddress = [param objectForKey:@"roadAddress"];
    
    NSArray *phoneNumbers = [param objectForKey:@"phoneNumbers"];
    UIImage *thumnail = [param objectForKey:@"thumnail"];
    NSArray *oldPhoneNumbers = [param objectForKey:@"oldPhoneNumbers"];
    NSString *oldName = [param objectForKey:@"oldName"];
    
    address = address ? address : @"";
    departmentName = departmentName ? departmentName : @"";
    emailAddresses = emailAddresses ? emailAddresses : @"";
    groupName = groupName ? groupName : @"";
    jobTitle = jobTitle ? jobTitle : @"";
    like = like;
    organizationName = organizationName ? organizationName : @"";
    roadAddress = roadAddress ? roadAddress : @"";
    
    //1개 이상이면

    NSString *tmpPhoneNumber = @"";
    
    if (oldPhoneNumbers.count == 1) {
        tmpPhoneNumber = [oldPhoneNumbers firstObject];
    }
    else if (oldPhoneNumbers.count > 1) {
        tmpPhoneNumber = [oldPhoneNumbers lastObject];
    }

    [self findContactToPhoneNumber:[oldPhoneNumbers lastObject] name:oldName completion:^(BOOL success, CNMutableContact * _Nullable contact) {
        if (success && contact) {
            
            NSError *error;
            CNContactStore *store = [[CNContactStore alloc] init];
            CNSaveRequest *saveReq = [[CNSaveRequest alloc] init];
            
            contact.familyName = @"";
            contact.givenName = name;
            
            NSMutableArray *arrPhone = [NSMutableArray array];
            for (NSMutableDictionary *itemDic in phoneNumbers) {
                NSString *label = [itemDic objectForKey:@"label"];
                NSString *phoneNumber = [itemDic objectForKey:@"number"];
                
                CNLabeledValue *cnLabel = [[CNLabeledValue alloc] initWithLabel:[self cnLabelPhoneNumberLabelToLocalLabel:label] value:[CNPhoneNumber phoneNumberWithStringValue:phoneNumber]];
                [arrPhone addObject:cnLabel];
            }
            
            contact.phoneNumbers = arrPhone;
            
    
            if (address.length > 0) {
                CNMutablePostalAddress *homeAddress = [[CNMutablePostalAddress alloc] init];
                NSArray *arrAddress = [address componentsSeparatedByString:@" "];
                
                NSString *state = nil;
                NSString *city = nil;
                NSMutableString *street = [NSMutableString string];
                
                for (int i = 0; i < arrAddress.count; i++ ) {
                    if ( i== 0) {
                        state = [arrAddress objectAtIndex:i];
                    }
                    else if (i == 1) {
                        city = [arrAddress objectAtIndex:i];
                    }
                    else if (i == 2) {
                        [street setString:[arrAddress objectAtIndex:i]];
                    }
                    else if (i == 3 || i == 4) {
                        [street appendString:[NSString stringWithFormat:@" %@",[arrAddress objectAtIndex:i]]];
                    }
                }
                homeAddress.state = state;
                homeAddress.city = city;
                homeAddress.street = street;
                contact.postalAddresses = @[[[CNLabeledValue alloc] initWithLabel:CNLabelHome value:homeAddress]];
                
            }
            else {
                NSMutableArray *arr = [contact.postalAddresses mutableCopy];
                [arr removeAllObjects];
                contact.postalAddresses = arr;
            }
            
            if (emailAddresses.length > 0) {
                NSMutableArray *emails = [NSMutableArray array];
                [emails addObject:[[CNLabeledValue alloc] initWithLabel:emailAddresses value:CNContactEmailAddressesKey]];
                contact.emailAddresses = emails;
            }
            else {
                NSMutableArray *arr = [contact.emailAddresses mutableCopy];
                [arr removeAllObjects];
                contact.emailAddresses = arr;
            }
            
            
            if (thumnail != nil) {
                contact.imageData = UIImagePNGRepresentation(thumnail);
            }
            else {
                contact.imageData = nil;
            }
            
            @try {
                [saveReq updateContact:contact];
                [store executeSaveRequest:saveReq error:&error];
                if (completion) {
                    completion ((error == nil), error);
                }
            }
            @catch (NSException *e) {
                if (completion) {
                    completion (NO, error);
                }
                
            }
        }
        else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}
- (void)findContactToPhoneNumber:(NSString *)phoneNumber
                       name:(NSString *)name
                      completion:(void (^)(BOOL success, CNMutableContact * _Nullable contact))completion {
    
    
    __block CNContact *findContact = nil;
    
    NSString *findPhoneNumber = phoneNumber;
    if ([findPhoneNumber isEqual: [NSNull null]] == NO && findPhoneNumber.length == 0) {
        findPhoneNumber = @"";
    }
    else {
        findPhoneNumber = [findPhoneNumber delPhoneFormater];
    }
    
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            
            NSArray *keys = @[CNContactIdentifierKey,
                              CNContactFamilyNameKey,
                              CNContactGivenNameKey,
                              CNContactJobTitleKey,
                              CNContactDepartmentNameKey,
                              CNContactOrganizationNameKey,
                              CNContactPhoneNumbersKey,
                              CNContactEmailAddressesKey,
                              CNContactPostalAddressesKey,
                              CNContactImageDataKey];
            
            NSString *containerId = contactStore.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                
                for (CNContact *contact in cnContacts) {
                    
                    NSMutableString *fullName = [NSMutableString string];
                    if ([contact.familyName isNotEmpty]) {
                        [fullName setString:contact.familyName];
                    }
                    
                    if ([contact.givenName isNotEmpty]) {
                        [fullName appendString:contact.givenName];
                    }
                    
                    
                    NSString *phonNumber = ((CNPhoneNumber *) ((CNLabeledValue *)[contact.phoneNumbers firstObject]).value).stringValue;
                    phonNumber = [phonNumber delPhoneFormater];
                    
                    
                    if ([fullName isEqualToString:name] && [findPhoneNumber isEqualToString:phonNumber]) {
                        findContact = contact;
                        break;
                    }
                }
                
                if (findContact != nil) {
                    if (completion) {
                        completion(YES, [findContact mutableCopy]);
                        return ;
                    }
                }
                else {
                    completion(NO, nil);
                    return;
                }
            }
        }
    }];
}
- (void)deleteAddressBook:(NSDictionary *)param completion:(void (^)(BOOL success, NSError *error))completion {
    
    NSString *name = [param objectForKey:@"name"];
    NSString *phoneNumber = [param objectForKey:@"phoneNumber"];
    
    [self findContactToPhoneNumber:phoneNumber name:name completion:^(BOOL success, CNMutableContact *contact) {
        
        if (success && contact != nil) {
            NSMutableArray *arrFetchKey = [NSMutableArray array];
            [arrFetchKey addObject:CNContactIdentifierKey];
            [arrFetchKey addObject:CNContactFamilyNameKey];
            [arrFetchKey addObject:CNContactGivenNameKey];
            [arrFetchKey addObject:CNContactPhoneNumbersKey];
            [arrFetchKey addObject:CNContactPostalAddressesKey];
            [arrFetchKey addObject:CNContactEmailAddressesKey];
            [arrFetchKey addObject:CNContactImageDataKey];
    
            __block NSError *error;
            CNContactStore *store = [[CNContactStore alloc] init];
            CNSaveRequest *saveReq = [[CNSaveRequest alloc] init];
            
    
            @try {
                [saveReq deleteContact:contact];
                [store executeSaveRequest:saveReq error:&error];
                if (error != nil) {
                    if (completion) {
                        completion(NO, error);
                    }
                }
                else {
                    if (completion) {
                        completion(YES, nil);
                    }
                }
            }
            @catch (NSException *e) {
                if (completion) {
                    completion(NO, error);
                }
            }
        }
        else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

@end
