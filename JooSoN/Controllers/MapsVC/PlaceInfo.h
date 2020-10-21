//
//  PlaceInfo.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/08.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PlaceInfo : NSObject
@property (nonatomic, strong) NSString *place_id;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, strong) NSString *jibun_address;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *road_address;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, assign) double x; //위도 lat
@property (nonatomic, assign) double y; //경도 lng
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *subLocality;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, strong) NSString *opening_hours;
@property (nonatomic, assign) BOOL selected;    // marker 
@end

NS_ASSUME_NONNULL_END
