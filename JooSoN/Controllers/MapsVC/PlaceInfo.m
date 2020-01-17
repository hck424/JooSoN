//
//  PlaceInfo.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/08.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "PlaceInfo.h"

@implementation PlaceInfo

- (NSString *)description {
    NSMutableString *des = [NSMutableString string];
    [des appendFormat:@"distance : %lf\r", _distance];
    [des appendFormat:@"jibun_address : %@\r", _jibun_address];
    [des appendFormat:@"name : %@\r", _name];
    [des appendFormat:@"phone_number : %@\r", _phone_number];
    [des appendFormat:@"road_address : %@\r", _road_address];
    [des appendFormat:@"sessionId : %@\r", _sessionId];
    [des appendFormat:@"x : %lf\r",  _x];
    [des appendFormat:@"y : %lf\r",  _y];
    return des;
}
@end
