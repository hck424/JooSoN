//
//  FavoriteListViewController.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteListViewController : UIViewController
- (void)reloadData;
- (void)setSearchText:(NSString *)searchStr;
@end
