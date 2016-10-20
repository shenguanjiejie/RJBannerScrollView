//
//  RJCollectionViewFlowLayout.m
//  duDu
//
//  Created by RuiJie on 16/10/12.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJCollectionViewFlowLayout.h"
#import "RJBannerInfo.h"

@interface RJCollectionViewFlowLayout ()
{

}
@end

@implementation RJCollectionViewFlowLayout

#if 0 //2016-10-18
/**
 *  这个方法用来设置scrollview停止滚动那一刻的位置
 *
 *  @param proposedContentOffset 原本scorllview停留那一刻的位置
 *  @param velocity              滚动速度
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{

    CGPoint point = [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];

    //如果正在调整位置,或正在拖拽,不能使用当前的offset,因为当前是野offset
    if ([RJBannerInfo sharedRJBannerInfo].currentOffset.x == 0) {
        [RJBannerInfo sharedRJBannerInfo].currentOffset = self.collectionView.contentOffset;
    }
//    NSLog(@"%s",__FUNCTION__);
#if 0
    
    
    //1.计算出scorllview最后会停留的位置
    CGRect lastRect ;
    lastRect.size = self.collectionView.frame.size;
//    lastRect.origin = proposedContentOffset;
    lastRect.origin = self.collectionView.contentOffset;
    
    //计算屏幕最中间的x
    CGFloat centerX = self.currentOffset.x + self.collectionView.frame.size.width * 0.5;
//    CGFloat centerX = ;
    
    //取出这个范围内的所有属性
    NSArray *array = [super layoutAttributesForElementsInRect:lastRect];
    
    //遍历这个范围内的所有属性
    CGFloat adjustOffset = 0;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (proposedContentOffset.x == self.currentOffset.x) {
            //如果还没有放手,仍在拖拽,则计算出的centerX其实是拖拽之前offset情况下的中心,则应取离中心最远的Cell到中心的距离
            if (attrs.center.x - centerX < 0) {
                adjustOffset = MIN(attrs.center.x - centerX, adjustOffset);
            }else{
                adjustOffset = MAX(attrs.center.x - centerX, adjustOffset);
            }
//            if (ABS(attrs.center.x - centerX) < ABS(adjustOffset)) {
//                adjustOffset = attrs.center.x - centerX;
//            }
        }else{
            adjustOffset = MIN(ABS(attrs.center.x - centerX), adjustOffset);
            
        }
    }
#endif

////    2016-10-18 modify
//    CGFloat currentCenter = self.currentOffset.x + self.collectionView.bounds.size.width / 2.0;
//    NSIndexPath *currentIndexPath = nil;
//    CGRect movedRect ;
//    movedRect.size = self.collectionView.frame.size;
//    movedRect.origin = self.collectionView.contentOffset;
//    
//    NSArray *array = [super layoutAttributesForElementsInRect:movedRect];
//    CGFloat distance = 0;
//    for (UICollectionViewLayoutAttributes *attrs in array) {
//        if (ABS(attrs.center.x - currentCenter) <= distance) {
//            distance = ABS(attrs.center.x - currentCenter);
//            currentIndexPath = attrs.indexPath;
//        }
//    }
    
    UICollectionViewLayoutAttributes *currentLayout = [self.collectionView layoutAttributesForItemAtIndexPath:[RJBannerInfo sharedRJBannerInfo].currentIndexPath];
    
    long step = proposedContentOffset.x > [RJBannerInfo sharedRJBannerInfo].currentOffset.x ? 1 : -1;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[RJBannerInfo sharedRJBannerInfo].currentIndexPath.row + step inSection:0];
    UICollectionViewLayoutAttributes *newLayout = [self.collectionView layoutAttributesForItemAtIndexPath:newIndexPath];
    //UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:newIndexPath];
    CGFloat pageWidth = self.minimumLineSpacing + currentLayout.size.width / 2.0 + newLayout.size.width / 2.0;
    CGFloat nowDistance = ABS([RJBannerInfo sharedRJBannerInfo].currentOffset.x - proposedContentOffset.x);
    
    if (nowDistance > pageWidth / 2.0) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[RJBannerInfo sharedRJBannerInfo].currentIndexPath];
        if (cell) {
            [UIView animateWithDuration:[RJBannerInfo sharedRJBannerInfo].transformDuration animations:^{
                cell.transform = [RJBannerInfo sharedRJBannerInfo].centerCellTransform;
            }];
        }
        [RJBannerInfo sharedRJBannerInfo].currentIndexPath = newIndexPath;
        [RJBannerInfo sharedRJBannerInfo].currentOffset = CGPointMake([RJBannerInfo sharedRJBannerInfo].currentOffset.x + step * pageWidth, 0);
    }
    
    NSLog(@"%s currentIndexPath = %@",__FUNCTION__,[RJBannerInfo sharedRJBannerInfo].currentIndexPath);
    return [RJBannerInfo sharedRJBannerInfo].currentOffset;
}
#endif
/**
 * 只要边界发生改变就会重新布局：重新调用layoutAttributesForElementsInRect：这个方法获得cell的所有布局属性
 */

#if 0 //2016-10-18
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
//    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    if (ABS(self.currentOffset.x - newBounds.origin.x) > self.minimumLineSpacing) {
        return YES;
    }
    return NO;
}

/**
 *准备cell的布局
 */
- (void)prepareLayout
{
    [super prepareLayout];
    // 设置cell的宽高
    //设置流水布局滚动方向为横向
//    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置cell的间距
//    self.minimumLineSpacing = LLPItemWH-20;//LLPItemWH
    //设置偏移量
//    CGFloat inset = (self.collectionView.frame.size.width - LLPItemWH+45) * 0.5;
    //    NSLog(@"inset %f",inset);
//    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
    
    
    //    NSLog(@"cell wide layout %f",self.itemSize.width);
    
    
}

/**
 *  每一个cell都有自己的UICollectionViewLayoutAttributes（布局属性）对cell进行缩放http://blog.csdn.net/qpwyj/article/details/51338337
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //获取每个cell的所有layoutAttributesForElementsInRect
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    //计算屏幕最中间的x
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    //拿到可见矩形框的cgrect
    CGRect visiableRect;
    visiableRect.size = self.collectionView.frame.size;
    visiableRect.origin = self.collectionView.contentOffset;
    
    CGFloat distance = 0;
    UICollectionViewLayoutAttributes *nearAttr = [[UICollectionViewLayoutAttributes alloc] init];
//    NSLog(@"%s",__FUNCTION__);
    //遍历数组中的UICollectionViewLayoutAttributes
    for (UICollectionViewLayoutAttributes *attrs in array) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:attrs.indexPath];
        [UIView animateWithDuration:0.3 animations:^{
            if (CGRectIntersectsRect(visiableRect, attrs.frame) && attrs.indexPath.row == self.currentIndexPath.row) {
                cell.layer.affineTransform = self.centerCellTransform;
            }else{
                cell.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
            }
        }];

#if 0
        /*只对显示在屏幕的cell进行缩放*/
        /*判断矩形框是否和屏幕相交*/
        if (!CGRectIntersectsRect(visiableRect, attrs.frame)) continue;
        
        //每一个cell的中点
        CGFloat itemCenter = attrs.center.x;
        
        //获取cell的中点和屏幕中点的差距的绝对值
        if (distance > ABS(itemCenter - centerX)) {
            nearAttr = attrs;
            distance = ABS(itemCenter - centerX);
        }
        
        //        NSLog(@"center.x %f",itemCenter);
        //根据中点差距计算缩放比例,差距小，缩放比例越大
//        CGFloat scale = 5 / 4.0 - 1 / 5.0 * (ABS(itemCenter - centerX) / self.collectionView.frame.size.width);
#endif
    }
    
    
    return array;
}

#endif

@end
