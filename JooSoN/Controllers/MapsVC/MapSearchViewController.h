//
//  MapSearchViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/11.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTextField.h"
#import "PlaceInfo.h"

IB_DESIGNABLE
NS_ASSUME_NONNULL_BEGIN
@protocol MapSearchViewControllerDelegate <NSObject>
- (void)mapSearchVCSelectedPlace:(PlaceInfo *)place;
@end
@interface MapSearchViewController : UIViewController
@property (nonatomic, strong) PlaceInfo *passPlaceInfo;
@property (nonatomic, strong) NSString *searchAddress;
@property (nonatomic, weak) id <MapSearchViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
