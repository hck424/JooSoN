//
//  InfoJooSoViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/03.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalButton.h"
#import "JooSo+CoreDataProperties.h"
#import "Thumnail+CoreDataProperties.h"
#import "History+CoreDataProperties.h"
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface InfoJooSoViewController : UIViewController
@property (nonatomic, strong) JooSo *passJooso;

@end

NS_ASSUME_NONNULL_END
