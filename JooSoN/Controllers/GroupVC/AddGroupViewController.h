//
//  AddGroupViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTextField.h"
#import "GroupName+CoreDataProperties.h"
typedef enum : NSUInteger {
    AddGroupTypeDefault,
    AddGroupTypeNew
} AddGroupType;

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface AddGroupViewController : UIViewController
@property (nonatomic, strong) GroupName *passGroup;
@property (nonatomic, assign) AddGroupType type;
@end

NS_ASSUME_NONNULL_END
