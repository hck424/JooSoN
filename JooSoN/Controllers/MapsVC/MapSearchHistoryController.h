//
//  MapSearchHistoryController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapSearchHistory+CoreDataProperties.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MapSearchHistoryControllerDelegate <NSObject>
@optional
- (void)mapSearchHistorySelItem:(MapSearchHistory *)history;
- (void)mapSearchHistoryHiden:(BOOL)hidden;
@end
@interface MapSearchHistoryController : UIViewController
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, weak) id <MapSearchHistoryControllerDelegate>delegate;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END

