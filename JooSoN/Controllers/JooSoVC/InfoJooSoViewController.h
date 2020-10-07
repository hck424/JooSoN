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
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE

@interface InfoJooSoViewController : BaseViewController
@property (nonatomic, strong) JooSo *passJooso;
@property (nonatomic, strong) History *passHistory;

@end

NS_ASSUME_NONNULL_END
