//
//  SearchJooSoListViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/28.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTextField.h"
#import "BGStackView.h"

typedef enum : NSUInteger {
    SearchViewTypeDefault,
    SearchViewTypeSelect,
    SearchViewTypeOption
} SearchViewType;
@protocol SearchJooSoListViewControllerDelegate <NSObject>
@optional
- (void)searchListViewCheckedList:(NSArray *)arrCheck;
@end
IB_DESIGNABLE
@interface SearchJooSoListViewController : UIViewController
@property (nonatomic, weak) id <SearchJooSoListViewControllerDelegate>delegate;
@property (nonatomic, strong) NSArray *arrOrigin;
@property (nonatomic, strong) NSString *selPhoneNumber;
@property (nonatomic, assign) SearchViewType viewType;

@property (nonatomic, strong) NSMutableArray *arrSelectedJooso;
- (void)reloadData;
@end
