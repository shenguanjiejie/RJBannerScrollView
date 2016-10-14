//
//  RJCollectionViewFlowLayout.m
//  duDu
//
//  Created by RuiJie on 16/10/12.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJCollectionViewFlowLayout.h"

@interface RJCollectionViewFlowLayout ()
{

}
@end

@implementation RJCollectionViewFlowLayout

/**
 *  这个方法用来设置scrollview停止滚动那一刻的位置
 *
 *  @param proposedContentOffset 原本scorllview停留那一刻的位置
 *  @param velocity              滚动速度
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //如果正在调整位置,或正在拖拽,不能使用当前的offset,因为当前是野offset
    if (self.currentOffset.x == 0) {
        self.currentOffset = self.collectionView.contentOffset;
    }
    
#if 0
    NSLog(@"%s currentOffsetX = %f",__FUNCTION__,self.currentOffset.x);
    
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

    CGFloat currentCenter = self.currentOffset.x + self.collectionView.bounds.size.width / 2.0;
    NSIndexPath *currentIndexPath = nil;
    CGRect movedRect ;
    movedRect.size = self.collectionView.frame.size;
    //    lastRect.origin = proposedContentOffset;
    movedRect.origin = self.collectionView.contentOffset;
    
    NSArray *array = [super layoutAttributesForElementsInRect:movedRect];
    CGFloat distance = 0;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(attrs.center.x - currentCenter) <= distance) {
            distance = ABS(attrs.center.x - currentCenter);
            currentIndexPath = attrs.indexPath;
        }
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];
    
    if (proposedContentOffset.x < self.currentOffset.x){
        self.currentIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row - 1 inSection:0];
        UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
        self.currentOffset = CGPointMake(self.currentOffset.x - (self.minimumLineSpacing + cell.frame.size.width / 2.0 + nextCell.frame.size.width / 2.0), 0);
    }else{
        self.currentIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
        UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
        self.currentOffset = CGPointMake(self.currentOffset.x + (self.minimumLineSpacing +cell.frame.size.width / 2.0 + nextCell.frame.size.width / 2.0), 0);
    }

    return self.currentOffset;
}
/**
 * 只要边界发生改变就会重新布局：重新调用layoutAttributesForElementsInRect：这个方法获得cell的所有布局属性
 */
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
    NSLog(@"%s",__FUNCTION__);
    //遍历数组中的UICollectionViewLayoutAttributes
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (CGRectIntersectsRect(visiableRect, attrs.frame) && attrs.indexPath.row == self.currentIndexPath.row) {
            attrs.transform = self.centerCellTransform;
            break;
        }
        
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



@end
