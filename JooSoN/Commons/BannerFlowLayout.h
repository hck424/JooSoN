//
//  BannerFlowLayout.h
//  JooSoN
//
//  Created by 김학철 on 2020/09/17.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BannerFlowLayoutDelegate <NSObject>
- (void)bannerFlowLayout:(CGPoint)curPoint indexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_BEGIN
@interface BannerFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) BOOL insertingTopCells;
@property (nonatomic, assign) CGSize sizeForTopInsertions;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, weak) id <BannerFlowLayoutDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
