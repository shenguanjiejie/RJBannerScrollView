//
//  RJBannerScrollView.m
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJBannerScrollView.h"
#import "RJBannerInfo.h"
#import "RJBannerCollectionCell.h"
#import "RJCollectionViewFlowLayout.h"

// 每一组最大的行数
#define RJTotalRowsInSection (5000 * self.bannerInfoArr.count)
#define RJDefaultRow ((long)(RJTotalRowsInSection * 0.5))

@interface RJBannerScrollView()  <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSTimer *_timer;
//    NSIndexPath *_currentIndexPath;
//    unsigned long _currentRow;
//    BOOL _isDraging;
}
@end

@implementation RJBannerScrollView


#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _timeInterval = 3.0;
//        _isDraging = NO;
        _autoScroll = YES;
        
        RJCollectionViewFlowLayout *layout= [[RJCollectionViewFlowLayout alloc]init];
//        layout.pageWidth = self.bounds.size.width;
        layout.centerCellTransform = CGAffineTransformMakeScale(1, 1);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
//        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[RJBannerCollectionCell class] forCellWithReuseIdentifier:@"Cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_collectionView];
        [self addSubview:_pageControl];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView,_pageControl);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0],
                               ]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame bannerInfoArr:(NSArray<RJBannerInfo *> *)bannerInfoArr{
    self = [self initWithFrame:frame];
    if (self) {
        self.bannerInfoArr = bannerInfoArr;
    }
    
    return self;
}

- (void)dealloc{
    [self removeTimer];
}

- (void)setBannerInfoArr:(NSArray<RJBannerInfo *> *)bannerInfoArr{
    _bannerInfoArr = bannerInfoArr;
//    _currentIndexPath = [NSIndexPath indexPathForRow:RJDefaultRow inSection:0];
//    _currentRow = RJDefaultRow;
    
    // 总页数
    self.pageControl.numberOfPages = bannerInfoArr.count;
    [_collectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:RJDefaultRow inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self RJBannerScrollView:self willAutoScrollToIndex:RJDefaultRow % self.bannerInfoArr.count indexPath:indexPath];
    if (!_timer) {
        [self addTimer];
    }
}

- (void)setAutoScroll:(BOOL)autoScroll{
    if (_autoScroll == autoScroll) return;
    
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        [self addTimer];
    }else{
        [self removeTimer];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing{
    if (_minimumLineSpacing == minimumLineSpacing) return;
    
    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    _minimumLineSpacing = minimumLineSpacing;
    layout.minimumLineSpacing = minimumLineSpacing;
    
}
//- (void)setPageWidth:(CGFloat)pageWidth{
//    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    _pageWidth = pageWidth;
//    layout.pageWidth = pageWidth;
//}

- (void)setCenterCellTransform:(CGAffineTransform)centerCellTransform{
    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    _centerCellTransform = centerCellTransform;
    layout.centerCellTransform = centerCellTransform;
}

#pragma mark - Event Response

#pragma mark - Private Methods

- (void)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView willAutoScrollToIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
    
    //为layout设置将要跳转到的cell位置的offset
    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.currentOffset = CGPointMake(self.collectionView.contentOffset.x + self.minimumLineSpacing + currentCell.frame.size.width / 2.0 + nextCell.frame.size.width / 2.0, 0);
    layout.currentIndexPath = indexPath;
    if ([self.delegate respondsToSelector:@selector(RJBannerScrollView:willAutoScrollToIndex:indexPath:)]) {
        [self.delegate RJBannerScrollView:self willAutoScrollToIndex:index indexPath:indexPath];
    }
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextAD) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)nextAD
{
//    if (_isDraging == YES) return;
    
//    long row = _currentIndexPath.row;
//    if ((row % self.bannerInfoArr.count)  == 0) { // 第0张图片
//        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:RJDefaultRow inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
//        row = RJDefaultRow;
//    }

//    NSLog(@"%s %ld",__FUNCTION__,_currentRow);
    long row = 0;
    NSArray *indexs =  [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexs) {
        row = MAX(row, index.row);
    }
//    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentRow + 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self RJBannerScrollView:self willAutoScrollToIndex:RJDefaultRow % self.bannerInfoArr.count indexPath:indexPath];
}

#pragma mark - 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return RJTotalRowsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"Cell";
    RJBannerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.placeholderImage = self.placeholderImage;
    cell.bannerInfo = self.bannerInfoArr[indexPath.row % self.bannerInfoArr.count];
    cell.titleLab.text = [NSString stringWithFormat:@"indexRow = %ld",indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%s indexRow = %ld",__FUNCTION__,indexPath.row);
    
    if ([self.delegate respondsToSelector:@selector(RJBannerScrollView:willDisplayingCell:atIndex: indexPath:)]) {
        [self.delegate RJBannerScrollView:self willDisplayingCell:cell atIndex:self.pageControl.currentPage indexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    _currentIndexPath = indexPath;
//    NSLog(@"%s indexRow = %ld",__FUNCTION__,indexPath.row);
//    NSArray *arr = [collectionView indexPathsForVisibleItems];
//    [(RJBannerCollectionCell *)cell titleLab].text = [NSString stringWithFormat:@"%ld, indexRow:%ld",_currentRow, indexPath.row];
//    if (!_isDraging) {
//        _currentRow = _currentRow + 2 > indexPath.row? indexPath.row - 2:indexPath.row + 2;
//        _currentRow = indexPath.row + 1;
//    }
    
//    self.pageControl.currentPage = indexPath.row % self.bannerInfoArr.count;
    
    if ([self.delegate respondsToSelector:@selector(RJBannerScrollView:didEndDisplayingCell:atIndex: indexPath:)]) {
        [self.delegate RJBannerScrollView:self didEndDisplayingCell:cell atIndex:self.pageControl.currentPage indexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(RJBannerScrollView:didSelectItemAtIndex:)]) {
        [self.delegate RJBannerScrollView:self didSelectItemAtIndex:indexPath.row % self.bannerInfoArr.count];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout


//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(RJBannerScrollView:sizeForItemAtIndex:)]) {
        return [self.delegate RJBannerScrollView:self sizeForItemAtIndex:indexPath.row % self.bannerInfoArr.count];
    }
    return self.bounds.size;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
////    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForRJBannerScrollView:)]) {
////        return [self.delegate minimumInteritemSpacingForRJBannerScrollView:self];
////    }
//    return self.minimumInteritemSpacing;
//}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%s 滚动动画停止了",__FUNCTION__);
    [self addTimer];
}


@end
