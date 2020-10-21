//
//  DBManager.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/21.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "DBManager.h"
#import "Utility.h"
#import "NSString+Utility.h"
#import "NSObject+Utility.h"
#import "PlaceInfo.h"

#define MAX_COUNT_SEARCHQUERY 10

NSString *NMAP_ORDERBY_WEIGHT = @"weight";
NSString *NMAP_ORDERBY_POPULARITY = @"popularity";

@interface DBManager ()

@property (nonatomic, strong) ContactsManager *contactsManager;
@property (nonatomic, strong) NSManagedObjectContext *viewContext;
@property (nonatomic, strong) NSCache *cache;
@end

@implementation DBManager

+ (DBManager *)instance {
    static DBManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DBManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
//        NSString *uuid = [Utility getUUID];
//        self.document = [[FIRFirestore.firestore collectionWithPath:@"uuids"] documentWithPath:uuid];
        self.contactsManager = [[ContactsManager alloc] init];
        self.viewContext = [AppDelegate instance].persistentContainer.viewContext;
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)loadContacts:(SUCCESS_ARR)success {
    
    [_contactsManager loadContactWidthCompletionBlok:^(NSArray *dataArr) {
        NSArray *arrSort = nil;
        if (dataArr.count > 0) {
            
            arrSort = [dataArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                NSString *name1 = [obj1 objectForKey:@"name"];
                NSString *name2 = [obj2 objectForKey:@"name"];
                
                NSString *tmp1 = @"0";
                if ([name1 localizedCaseInsensitiveCompare:@"ㄱ"]+1) {
                    tmp1 = @"0";
                }
                else {
                    if (!([name2 localizedCaseInsensitiveCompare:@"a"]+1)) {
                        tmp1 = @"2";
                    }
                    else {
                        tmp1 = @"1";
                    }
                }
                name1 = [NSString stringWithFormat:@"%@%@",tmp1, name1];
                
                name1 = [NSString stringWithFormat:@"%@%@",
                         ([name1 localizedCaseInsensitiveCompare:@"ㄱ"]+1) ? @"0" :
                         !([name1 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                         @"1", name1];
                
                name2 = [NSString stringWithFormat:@"%@%@",
                         ([name2 localizedCaseInsensitiveCompare:@"ㄱ"]+1) ? @"0" :
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

- (JooSo *)createJooSoToDictionary:(NSDictionary *)itemDic {
    if (itemDic == nil) {
        return nil;
    }
    
    NSString *contactIdentifier = [itemDic objectForKey:@"contactIdentifier"];
    NSString *localIdentifier = [itemDic objectForKey:@"localIdentifier"];
    NSString *name = [itemDic objectForKey:@"name"];
    NSString *address = [itemDic objectForKey:@"address"];
    NSString *departmentName = [itemDic objectForKey:@"departmentName"];
    NSString *emailAddresses = [itemDic objectForKey:@"emailAddresses"];
    double geoLat = [[itemDic objectForKey:@"geoLat"] doubleValue];
    double geoLng = [[itemDic objectForKey:@"geoLng"] doubleValue];
    
    NSString *groupName = [itemDic objectForKey:@"groupName"];
    NSString *jobTitle = [itemDic objectForKey:@"jobTitle"];
    BOOL like = [[itemDic objectForKey:@"like"] boolValue];
    
    NSString *organizationName = [itemDic objectForKey:@"organizationName"];
    NSString *roadAddress = [itemDic objectForKey:@"roadAddress"];
    NSString *placeName = [itemDic objectForKey:@"placeName"];
    NSArray *phoneNumbers = [itemDic objectForKey:@"phoneNumbers"];
    UIImage *thumnail = [itemDic objectForKey:@"thumnail"];
    
    JooSo *js = [NSEntityDescription insertNewObjectForEntityForName:EntityJooSo inManagedObjectContext:_viewContext];
    
    js.contactIdentifier = contactIdentifier;
    js.localIdentifier = localIdentifier;
    js.name = name;
    js.address = address;
    js.departmentName = departmentName;
    js.emailAddresses = emailAddresses;
    js.geoLat = geoLat;
    js.geoLng = geoLng;
    js.groupName = groupName;
    js.jobTitle = jobTitle;
    js.like = like;
    js.organizationName = organizationName;
    js.roadAddress = roadAddress;
    js.placeName = placeName;
    
    for (NSDictionary *itemDic in phoneNumbers) {
        NSString *label = [itemDic objectForKey:@"label"];
        NSString *number = [itemDic objectForKey:@"number"];
        BOOL isMainPhone = [[itemDic objectForKey:@"isMainPhone"] boolValue];
        
        PhoneNumber *ph = [NSEntityDescription insertNewObjectForEntityForName:EntityPhoneNumber inManagedObjectContext:_viewContext];
        
        ph.label = label;
        ph.number = number;
        ph.isMainPhone = isMainPhone;
        
        [js addToPhoneNumberObject:ph];
    }
    
    if (thumnail != nil) {
        Thumnail *thum = [NSEntityDescription insertNewObjectForEntityForName:EntityThumnail inManagedObjectContext:_viewContext];
        thum.image = thumnail;
        js.toThumnail = thum;
    }
    
    return js;
}

- (void)uploadAllContactsToLocalDB:(NSArray *)arrData success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    NSError *error = nil;
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityJooSo];
    NSBatchDeleteRequest *deleteReq = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchReq];
    NSError *errDel = nil;
    [_viewContext executeRequest:deleteReq error:&errDel];
    if (errDel != nil) {
        NSLog(@"error : %@", error.localizedDescription);
    }
    else {
        NSLog(@"all jooso delete success");
    }
    
    for (NSDictionary *itemDic in arrData) {
        [self createJooSoToDictionary:itemDic];
        NSError *errSave = nil;
        
        if ([_viewContext save:&errSave] == NO) {
            NSLog(@"error localdb not save contact: %@", errSave.localizedDescription);
            error = errSave;
        }
    }
    
    if (success) {
        success();
    }
    else if (fail) {
        fail(error);
    }
}

#pragma mark -- JooSo Query
- (void)insertJooSo:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    
    [self createJooSoToDictionary:param];
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

- (void)updateWidthJooSo:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
    [_viewContext refreshAllObjects];
}

- (void)updateJooSo:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    JooSo *oldJooso = [param objectForKey:@"oldJooSo"];
    oldJooso.contactIdentifier = [param objectForKey:@"contactIdentifier"];
    oldJooso.localIdentifier = [param objectForKey:@"localIdentifier"];
    oldJooso.name = [param objectForKey:@"name"];
    oldJooso.address = [param objectForKey:@"address"];
    oldJooso.departmentName = [param objectForKey:@"departmentName"];
    oldJooso.emailAddresses = [param objectForKey:@"emailAddresses"];
    oldJooso.geoLat = [[param objectForKey:@"geoLat"] doubleValue];
    oldJooso.geoLng = [[param objectForKey:@"geoLng"] doubleValue];
    
    oldJooso.groupName = [param objectForKey:@"groupName"];
    oldJooso.jobTitle = [param objectForKey:@"jobTitle"];
    oldJooso.like = [[param objectForKey:@"like"] boolValue];
    
    oldJooso.organizationName = [param objectForKey:@"organizationName"];
    oldJooso.roadAddress = [param objectForKey:@"roadAddress"];
    oldJooso.placeName = [param objectForKey:@"placeName"];
    UIImage *thumnail = [param objectForKey:@"thumnail"];
    oldJooso.toThumnail.image = thumnail;
        
    NSArray *phoneNumbers = [param objectForKey:@"phoneNumbers"];

    [oldJooso removeToPhoneNumber:oldJooso.toPhoneNumber];
    
    for (NSDictionary *itemDic in phoneNumbers) {
        NSString *number = [itemDic objectForKey:@"number"];
        NSString *label = [itemDic objectForKey:@"label"];
        BOOL isMainPhone = [[itemDic objectForKey:@"isMainPhone"] boolValue];
        
        PhoneNumber *ph = [NSEntityDescription insertNewObjectForEntityForName:EntityPhoneNumber inManagedObjectContext:_viewContext];
        ph.number = number;
        ph.label = label;
        ph.isMainPhone = isMainPhone;
        
        [oldJooso addToPhoneNumberObject:ph];
    }
    
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
    [_viewContext refreshAllObjects];
}

- (void)deleteJooSo:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    [_viewContext deleteObject:jooso];
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

- (void)getAllJooSo:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityJooSo];
    
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    
    if (error != nil) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            
           NSArray *arrSort = [result sortedArrayUsingComparator:^NSComparisonResult(JooSo *obj1, JooSo *obj2) {
                NSString *name1 = obj1.name;
                NSString *name2 = obj2.name;
                
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
            
            success(arrSort);
        }
    }
}

#pragma mark - Like JooSo Query
- (void)updateLike:(JooSo *)jooso success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
    [_viewContext refreshAllObjects];
}

- (void)getAllLike:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityJooSo];
    NSString *attributeName = @"like";
    NSNumber *itemValue = [NSNumber numberWithBool:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",attributeName,itemValue];
    [fetchReq setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    if (error != nil) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success(result);
        }
    }
}

- (void)findJoosoWithPhoneNumber:(NSString *)phoneNumber name:(NSString *)name success:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityJooSo];
    
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    NSMutableArray *findArr = [NSMutableArray array];
    
    if (error != nil) {
        if (fail) {
            fail(error);
        }
    }
    else {
        for (JooSo *jooso in result) {
            NSString *number = [[jooso getMainPhone] delPhoneFormater];
            if ([[phoneNumber delPhoneFormater] isEqualToString:number] && [jooso.name isEqualToString:name]) {
                [findArr addObject:jooso];
            }
        }
        
        if (success) {
            success(findArr);
        }
    }
}

- (void)getGroupNameJooSoList:(NSString *)groupName success:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
 
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityJooSo];
    
    NSString *attributeName = @"groupName";
    NSString *itemValue = groupName;
    NSPredicate *predicate = nil;
    if ([groupName isEqualToString:@"전체"]) {
        predicate = [NSPredicate predicateWithFormat:@"(%K != nil) OR %K.length > 0", attributeName, attributeName];
    }
    else if ([groupName isEqualToString:@"NO"]) {
        predicate = [NSPredicate predicateWithFormat:@"(%K == nil) OR %K.length == 0", attributeName, attributeName];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", attributeName, itemValue];
    }
    [fetchReq setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    if (error != nil) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success(result);
        }
    }
}

#pragma mark - History Query
- (void)getAllHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO];
    NSArray *arrSortedDes = @[sortDes];
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityHistory];
    [fetchReq setSortDescriptors:arrSortedDes];
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    if (error != nil) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success(result);
        }
    }
}

- (History *)getLastHistoryOjbect {
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO];
    NSArray *arrSortedDes = @[sortDes];
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityHistory];
    [fetchReq setSortDescriptors:arrSortedDes];
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    if (error != nil) {
        NSLog(@"error : history get all : %@", error.localizedDescription);
    }
    
    if (result.count > 0) {
        return [result firstObject];
    }
    return nil;
}

- (BOOL)isUpdateHistoryDB:(NSDictionary *)param lastHistory:(History *)lastHistory {
    
    if (lastHistory == nil) {
        return NO;
    }
    
    
    NSString *phoneNumber = [param objectForKey:@"phoneNumber"];
    NSString *callState = [param objectForKey:@"callState"];
    NSString *callType = [param objectForKey:@"callType"];
    
    if ([[lastHistory.phoneNumber delPhoneFormater] isEqualToString:[phoneNumber delPhoneFormater]]
        && [lastHistory.callState isEqualToString:callState]
        && [lastHistory.callType isEqualToString:callType]) {
        return YES;
    }
    
    return NO;
}

- (void)insertHistory:(NSDictionary *)param success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    
    NSString *name = [param objectForKey:@"name"];
    NSString *phoneNumber = [param objectForKey:@"phoneNumber"];
    NSString *callState = [param objectForKey:@"callState"];
    NSString *callType = [param objectForKey:@"callType"];
    NSDate *createDate = [param objectForKey:@"createDate"];
    double takeCalling = [[param objectForKey:@"takeCalling"] doubleValue];
    NSInteger callCnt = [[param objectForKey:@"callCnt"] integerValue];
    NSString *address = [param objectForKey:@"address"];
    double geoLat = [[param objectForKey:@"geoLat"] doubleValue];
    double geoLng = [[param objectForKey:@"geoLng"] doubleValue];
    NSInteger historyType = [[param objectForKey:@"historyType"] integerValue];
    
    History *lastHistory = [self getLastHistoryOjbect];
    
    if ([self isUpdateHistoryDB:param lastHistory:lastHistory]) {
        lastHistory.callCnt = lastHistory.callCnt + 1;
        lastHistory.createDate = createDate;
        lastHistory.callState = callState;
        lastHistory.callType = callType;
        lastHistory.takeCalling = takeCalling;
        lastHistory.address = address;
        lastHistory.geoLat = geoLat;
        lastHistory.geoLng = geoLng;
        lastHistory.historyType = historyType;
        NSError *error = nil;
        if ([_viewContext save:&error] == NO) {
            if (fail) {
                fail(error);
            }
            else {
                if (success) {
                    success();
                }
            }
        }
        [_viewContext refreshAllObjects];
    }
    else {
        History *history = [NSEntityDescription insertNewObjectForEntityForName:EntityHistory inManagedObjectContext:_viewContext];
        
        history.name = name;
        history.phoneNumber = phoneNumber;
        history.callCnt = callCnt;
        history.createDate = createDate;
        history.callType = callType;
        history.callState = callState;
        history.takeCalling = takeCalling;
        history.address = address;
        history.geoLat = geoLat;
        history.geoLng = geoLng;
        history.historyType = historyType;
        
        NSError *error = nil;
        
        if ([_viewContext save:&error] == NO) {
            NSLog(@"error : histtable not save > %@", error.localizedDescription);
            if (fail) {
                fail (error);
            }
        }
        else {
            if (success) {
                NSLog(@"success history table insert");
                success();
            }
        }
        [_viewContext refreshAllObjects];
    }
}
- (void)deleteHistory:(History *)history success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    
    [_viewContext deleteObject:history];
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

#pragma mark - GroupName Quary
- (void)insertGroupName:(NSString *)groupName count:(NSInteger)count success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    if (groupName.length == 0) {
        if (fail) {
            NSLog(@"eror: not insert group name empty string");
            fail(nil);
            return;
        }
    }
    
    GroupName *group = [NSEntityDescription insertNewObjectForEntityForName:EntityGroupName inManagedObjectContext:_viewContext];
    group.name = groupName;
    group.count = count;
    NSError *error = nil;
    
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail (error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}
- (void)updateGroupName:(GroupName *)group success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    
    NSError *error = nil;
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
    [_viewContext refreshAllObjects];
}
- (void)getAllGroupName:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityGroupName];
    
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    
    if (error != nil) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success(result);
        }
    }
}

- (void)deleteGroupName:(GroupName *)group success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    NSError *error = nil;
    [_viewContext deleteObject:group];
    
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

//mapsearch history
- (void)getAllMapSearchHistory:(SUCCESS_ARR)success fail:(FAIL_ERROR)fail {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityMapSearchHistory];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [fetchReq setSortDescriptors:@[descriptor]];
    NSError *error = nil;
    NSArray *result = [_viewContext executeFetchRequest:fetchReq error:&error];
    if (error != nil) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success(result);
        }
    }
}

- (void)insertMapSearchHistory:(NSString *)text success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:EntityMapSearchHistory];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"text", text];
    [fetchReq setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *arr = [_viewContext executeFetchRequest:fetchReq error:&error];
    
    if (arr.count > 0) {
        MapSearchHistory *mapHistory = [arr firstObject];
        mapHistory.date = [NSDate date];
        if ([_viewContext save:&error] == NO) {
            if (fail) {
                fail (error);
            }
        }
        else {
            if (success) {
                success ();
            }
        }
    }
    else {
        MapSearchHistory *mapHistory = [NSEntityDescription insertNewObjectForEntityForName:EntityMapSearchHistory inManagedObjectContext:_viewContext];
        
        mapHistory.text = text;
        mapHistory.date = [NSDate date];
        NSError *error = nil;
        if ([_viewContext save:&error] == NO) {
            if (fail) {
                fail(error);
            }
        }
        else {
            if (success) {
                success();
            }
        }
    }
}
- (void)deleteMapSearchHistory:(MapSearchHistory *)history success:(SUCCESS_VOID)success fail:(FAIL_ERROR)fail {
    [_viewContext deleteObject:history];
    NSError *error = nil;
    
    if ([_viewContext save:&error] == NO) {
        if (fail) {
            fail(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

- (void)googleMapSearchPlace:(NSString *)query
                        type:(NSString *)type
                  coordinate:(CLLocationCoordinate2D)coordinate
                      circle:(NSUInteger)circle
                     success:(SUCCESS_DIC)success
                        fail:(FAIL_ERROR)fail {
    
    if ([type isEqualToString:@"R"] && CLLocationCoordinate2DIsValid(coordinate)) {
        coordinate.latitude = 37.5666102;
        coordinate.longitude = 126.9783881;
    }
    
    NSMutableString *result = [NSMutableString string];
    [result setString:@"https://maps.googleapis.com/maps/api/place/textsearch/json?"];
    [result appendFormat:@"query=%@", query];
    if ([type isEqualToString:@"R"]) {
        [result appendFormat:@"&location=%lf,%lf", coordinate.latitude, coordinate.longitude];
        [result appendFormat:@"&radius=%ld", circle];
        [result appendFormat:@"&fields=%@", @"formatted_address,opening_hours,rating"];
    }
    else {
        [result appendFormat:@"&fields=%@", @"formatted_address"];
    }
    [result appendFormat:@"&language=%@", @"ko"];
    [result appendFormat:@"&key=%@", GoogleMapWebApiKey];
    
    NSString *enResult = [result stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:enResult]];
    req.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"=== search place response state : %ld", httpResponse.statusCode);
            if(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300) {
                
                NSError *parseError = nil;
                NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                NSLog(@"=== search place : %@", resDic);
                if (parseError != nil) {
                    if (fail) {
                        fail(parseError);
                    }
                }
                else {
                    if (success) {
                        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                        [resultDic setObject:[resDic objectForKey:@"status"] forKey:@"status"];
                        NSString *next_page_token = [resDic objectForKey:@"next_page_token"];
                        if (next_page_token.length > 0) {
                            [resultDic setObject:next_page_token forKey:@"next_page_token"];
                        }
                        
                        NSArray *arrResult = [resDic objectForKey:@"results"];
                        NSMutableArray *arr = [NSMutableArray array];
                        for (NSDictionary *itemDic in arrResult) {
                            
                           __block PlaceInfo *info = [[PlaceInfo alloc] init];
                            info.jibun_address = [itemDic objectForKey:@"formatted_address"];
                            info.name = [itemDic objectForKey:@"name"];
                            NSDictionary *geometryDic = [itemDic objectForKey:@"geometry"];
                            
                            info.x = [[[geometryDic objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
                            info.y = [[[geometryDic objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
                            info.place_id = [itemDic objectForKey:@"place_id"];
                            if (info.x == 0.0 && info.y == 0.0) {
                                info.x = [[[[geometryDic objectForKey:@"viewport"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue];
                                info.y = [[[[geometryDic objectForKey:@"viewport"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue];
                            }
                            
                            [arr addObject:info];
                        }
                        [resultDic setObject:arr forKey:@"places"];
                        
                        success(resultDic);
                    }
                }
            }
            else {
                if (fail) {
                    fail(error);
                }
            }
        });
    }];
    
    [dataTask resume];
}

//Chahe 사용
- (void)reqeustDetailInfoWithPlaceId:(NSString *)placeId
                            userInfo:(id)userInfo
                             success:(SUCCESS_DIC)success
                                fail:(FAIL_ERROR)fail
{
    
    if (placeId == nil) {
        fail(nil);
        return;
    }
    __block id myInfo = userInfo;
    if ([_cache objectForKey:placeId] != nil) {
        NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
        [resDic setObject:[_cache objectForKey:placeId] forKey:@"data"];
        [resDic setObject:myInfo forKey:@"userInfo"];
        success(resDic);
        return;
    }
    
    NSMutableString *url = [NSMutableString string];
    [url setString:@"https://maps.googleapis.com/maps/api/place/details/json?"];
    [url appendFormat:@"place_id=%@", placeId];
    [url appendFormat:@"&fields=%@", @"name,rating,formatted_phone_number"];
    [url appendFormat:@"&key=%@", GoogleMapWebApiKey];
    
    NSString *enUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:enUrl]];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"=== search place response state : %ld", httpResponse.statusCode);
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300) {
                NSError *parseError = nil;
                NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                NSLog(@"=== search place : %@", resDic);
                if (parseError != nil) {
                    if (fail) {
                        fail(parseError);
                    }
                }
                else {
                    if (success) {
                        NSDictionary *result = [resDic objectForKey:@"result"];
                        if (result != nil) {
                            [self.cache setObject:result forKey:placeId];
                            
                            NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
                            [resDic setObject:result forKey:@"data"];
                            [resDic setObject:myInfo forKey:@"userInfo"];
                            
                            success(resDic);
                        }
                    }
                    else {
                        fail(nil);
                    }
                }
            }
            else {
                if (fail) {
                    fail(error);
                }
            }
        });
    }];
    
    [dataTask resume];
}

- (NSDictionary *)requestSynchronousPlaceDetailInfo:(NSString *)placeId {
    if (placeId == nil) {
        return  nil;
    }
    
    NSMutableString *url = [NSMutableString string];
    [url setString:@"https://maps.googleapis.com/maps/api/place/details/json?"];
    [url appendFormat:@"place_id=%@", placeId];
    [url appendFormat:@"&fields=%@", @"name,rating,formatted_phone_number"];
    [url appendFormat:@"&key=%@", GoogleMapWebApiKey];
    
    NSString *enUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:enUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    __block NSDictionary *responseDic = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSLog(@"%@", error);
            NSError *parseError = nil;
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (resDic != nil) {
                responseDic = resDic;
                
            }
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return responseDic;
}

@end
