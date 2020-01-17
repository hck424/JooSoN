//
//  MapSearchView.h
//  JooSoN
//
//  Created by 김학철 on 2020/01/09.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceInfo.h"

typedef enum : NSInteger {
    MapCellActionDefault = 0,
    MapCellActionNfc,
    MapCellActionNavi,
    MapCellActionSave
} MapCellAction;

NS_ASSUME_NONNULL_BEGIN
@interface MapSearchView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnNavi;
@property (weak, nonatomic) IBOutlet UIStackView *svContent;
@property (weak, nonatomic) IBOutlet UIView *bgView;


@property (nonatomic, copy) void (^onTouchUpInSideAction) (MapCellAction actionType, PlaceInfo *data);
- (void)configurationData:(PlaceInfo *)info;
- (void)setOnTouchUpInSideAction:(void (^ _Nonnull)(MapCellAction actionType, PlaceInfo *data))onTouchUpInSideAction;

@end

NS_ASSUME_NONNULL_END
