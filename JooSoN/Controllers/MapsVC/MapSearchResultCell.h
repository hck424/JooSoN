//
//  MapSearchResultCell.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Utility.h"
#import "PlaceInfo.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum : NSInteger {
    MapSearchCellActionNfc = 0,
    MapSearchCellActionNavi,
    MapSearchCellActionSave
} MapSearchCellAction;


@interface MapSearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, copy) void (^onTouchUpInSideAction) (MapSearchCellAction action, PlaceInfo *data);
- (void)configurationData:(PlaceInfo *)info;
- (void)setOnTouchUpInSideAction:(void (^ _Nonnull)(MapSearchCellAction action, PlaceInfo *data))onTouchUpInSideAction;
@end

NS_ASSUME_NONNULL_END
