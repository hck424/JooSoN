//
//  MapSearchCell.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/17.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Utility.h"
#import "PlaceInfo.h"
#import "Define.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapSearchCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, copy) void (^onTouchUpInSideAction) (MapCellAction action, PlaceInfo *data);
- (void)configurationData:(PlaceInfo *)info;
- (void)setOnTouchUpInSideAction:(void (^ _Nonnull)(MapCellAction action, PlaceInfo *data))onTouchUpInSideAction;

@end

NS_ASSUME_NONNULL_END
