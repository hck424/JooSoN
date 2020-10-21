//
//  TotalJooSoListViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History+CoreDataProperties.h"
#import "BaseViewController.h"
@interface TotalJooSoListViewController : BaseViewController
- (void)reloadData;
- (void)setSearchText:(NSString *)searchTxt;
@end
