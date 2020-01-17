//
//  MapSearchResultListController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceInfo.h"

NS_ASSUME_NONNULL_BEGIN
@interface MapSearchResultListController : UIViewController

@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) PlaceInfo *curPlaceInfo;
@end

NS_ASSUME_NONNULL_END
