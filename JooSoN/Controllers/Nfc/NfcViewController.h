//
//  NfcViewController.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/10.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JooSo+CoreDataProperties.h"
#import "PlaceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NfcViewController : UIViewController
@property (nonatomic, strong) PlaceInfo *passPlaceInfo;
@end

NS_ASSUME_NONNULL_END
