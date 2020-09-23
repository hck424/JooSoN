//
//  MapAddressSaveViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/21.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceInfo.h"
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface MapAddressSaveViewController : BaseViewController
@property (nonatomic, strong) PlaceInfo *passPlaceInfo;
@end

NS_ASSUME_NONNULL_END
