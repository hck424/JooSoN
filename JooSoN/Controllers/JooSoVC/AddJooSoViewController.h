//
//  AddJooSoViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JooSo+CoreDataProperties.h"
#import "Thumnail+CoreDataProperties.h"
#import "PhoneNumber+CoreDataProperties.h"
#import "History+CoreDataProperties.h"
#import "PlaceInfo.h"

IB_DESIGNABLE

typedef enum : NSUInteger {
    ViewTypeAdd,
    ViewTypeModi
} ViewType;

@interface AddJooSoViewController : UIViewController
@property (nonatomic, assign) ViewType viewType;
@property (nonatomic, strong) JooSo *passJooso;
@property (nonatomic, strong) History *passHistory;
@property (nonatomic, strong) NSString *passPhoneNumber;
@property (nonatomic, strong) PlaceInfo *placeInfo;
@end
