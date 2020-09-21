//
//  BannerFlowLayout.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/17.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "BannerFlowLayout.h"

@implementation BannerFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    CGSize oldSize = _sizeForTopInsertions;
    if (_insertingTopCells) {
        CGSize newSize = self.collectionView.contentSize;
        CGFloat xOffset = self.collectionView.contentOffset.x + (newSize.width - oldSize.width);
        CGPoint newOffset = CGPointMake(xOffset, self.collectionView.contentOffset.y);
        self.collectionView.contentOffset = newOffset;
    }
    else {
        _insertingTopCells = NO;
    }
    _sizeForTopInsertions = self.collectionView.contentSize;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:self.collectionView.bounds];
    
    if (layoutAttributes.count == 0) {
        return proposedContentOffset;
    }
    
    NSInteger targetIndex = layoutAttributes.count/2;
    CGFloat vX = velocity.x;
    if (vX > 0) {
        targetIndex += 1;
    }
    else if (vX < 0) {
        targetIndex -= 1;
    }
    else {
        return _lastPoint;
    }
    
    if (targetIndex >= layoutAttributes.count) {
        targetIndex = layoutAttributes.count - 1;
    }
    if (targetIndex < 0) {
        targetIndex = 0;
    }
    
    UICollectionViewLayoutAttributes *targetAttribute = [layoutAttributes objectAtIndex:targetIndex];
    _lastPoint = CGPointMake(targetAttribute.center.x - self.collectionView.bounds.size.width/2, proposedContentOffset.y);
    if ([self.delegate respondsToSelector:@selector(bannerFlowLayout:indexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetAttribute.indexPath.row inSection:targetAttribute.indexPath.section];
        [_delegate bannerFlowLayout:_lastPoint indexPath:indexPath];
    }
    
    return _lastPoint;
}

@end
