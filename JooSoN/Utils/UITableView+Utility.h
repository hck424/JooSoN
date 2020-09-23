//
//  UITableView+Utility.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/21.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Utility)
- (void)reloadData:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
