//
//  UITableView+Utility.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/21.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "UITableView+Utility.h"

@implementation UITableView (Utility)
- (void)reloadData:(void (^)(void))completion {
    
    [UIView animateWithDuration:0 animations:^{
        [self reloadData];
    } completion:^(BOOL finished) {
        completion();
    }];}
@end
