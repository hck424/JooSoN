//
//  DestinationViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTextField.h"
#import "BGStackView.h"
#import "MapSearchHistory+CoreDataProperties.h"
#import "BaseViewController.h"
IB_DESIGNABLE
@interface DestinationViewController : BaseViewController
- (void)reloadData;
@end
