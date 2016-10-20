//
//  RJBannerView.m
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJBannerView.h"
#import "RJBannerCollectionCell.h"
#import "RJCollectionViewFlowLayout.h"
#import "RJBannerInfo.h"

#define RJTotleRow (5000 * _count)
#define RJDefaultRow (RJTotleRow * 0.5)
#define RJIndex(indexPathRow) ((indexPathRow) % _count)

@interface RJBannerView()  <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSTimer *_timer;
    CGPoint _currentOffset;
    NSIndexPath *_currentIndexPath;
    unsigned long _count;
}

@property (nonatomic,weak) id<RJBannerViewDelegateFlowLayout> flowLayout;

@end

@implementation RJBannerView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _timeInterval = 3.0;
        _autoScroll = YES;
        _transformDuration = 0.3;
        _centerCellTransform = CGAffineTransformMakeScale(1.0, 1.0);

        RJCollectionViewFlowLayout *layout= [[RJCollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[RJBannerCollectionCell class] forCellWithReuseIdentifier:@"Cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.decelerationRate = 0;
        [self addSubview:_collectionView];
        
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)dealloc{
    [self removeTimer];
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

- (void)setPageControl:(UIPageControl *)pageControl{
    if (pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = pageControl;
    }else{
        [_pageControl removeFromSuperview];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing{
    if (_minimumLineSpacing == minimumLineSpacing) return;
    
    _minimumLineSpacing = minimumLineSpacing;
    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.minimumLineSpacing = minimumLineSpacing;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing{
    if (_minimumInteritemSpacing == minimumInteritemSpacing) return;
    
    _minimumInteritemSpacing = minimumInteritemSpacing;
    RJCollectionViewFlowLayout *layout = (RJCollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
}

- (void)setDelegate:(id<RJBannerViewDelegate>)delegate{
    _delegate = delegate;
    self.flowLayout = (id<RJBannerViewDelegateFlowLayout>)delegate;
}

#pragma mark - Event Response

#pragma mark - Private Methods

- (void)reloadData{
    [self.collectionView reloadData];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:RJDefaultRow inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        _currentOffset = _collectionView.contentOffset;
        _currentIndexPath = indexPath;
        if (!_timer) {
            [self addTimer];
        }
    });
}

- (void)RJBannerView:(RJBannerView *)bannerView willAutoScrollToIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath{
    
    self.pageControl.currentPage = index;
    UICollectionViewCell *nextCell = [_collectionView cellForItemAtIndexPath:indexPath];
    UICollectionViewCell *currentCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
#if 0
    [UIView animateWithDuration:self.transformDuration animations:^{
        currentCell.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        nextCell.layer.affineTransform = self.centerCellTransform;
    }];
#endif
    //为layout设置将要跳转到的cell位置的offset
    _currentOffset = CGPointMake(_collectionView.contentOffset.x + self.minimumLineSpacing + currentCell.frame.size.width / 2.0 + nextCell.frame.size.width / 2.0, 0);
    _currentIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(RJBannerView:willAutoScrollToIndex:)]) {
        [self.delegate RJBannerView:self willAutoScrollToIndex:index];
    }
}

- (void)removeTimer
{
    if (!_timer) return;
    
    [_timer invalidate];
    _timer = nil;
}

- (void)addTimer
{
    if (_timer) return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextCell) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)nextCell
{
    long row = 0;
    NSArray *indexs =  [_collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexs) {
        row = MAX(row, index.row);
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self RJBannerView:self willAutoScrollToIndex:RJIndex(indexPath.row) indexPath:indexPath];
}

#pragma mark - 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInRJBannerView:)]) {
        _count = [self.dataSource numberOfItemsInRJBannerView:self];

        if (self.pageControl) {
            self.pageControl.numberOfPages = _count;
        }

        return RJTotleRow;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"Cell";
    RJBannerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if (indexPath.row == RJDefaultRow) {
        cell.transform = self.centerCellTransform;
    }
    cell.placeholderImage = self.placeholderImage;
    if ([self.dataSource respondsToSelector:@selector(RJBannerView:bannerDataForItemAtIndex:)]) {
       cell.bannerData = [self.dataSource RJBannerView:self bannerDataForItemAtIndex:RJIndex(indexPath.row)];
    }

//    cell.titleLab.text = [NSString stringWithFormat:@"indexRow = %ld",indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(RJBannerView:willDisplayingCell:atIndex:)]) {
        [self.delegate RJBannerView:self willDisplayingCell:cell atIndex:self.pageControl.currentPage];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(RJBannerView:didEndDisplayingCell:atIndex:)]) {
        [self.delegate RJBannerView:self didEndDisplayingCell:cell atIndex:self.pageControl.currentPage];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(RJBannerView:didSelectItemAtIndex:)]) {
        [self.delegate RJBannerView:self didSelectItemAtIndex:RJIndex(indexPath.row)];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.flowLayout respondsToSelector:@selector(RJBannerView:sizeForItemAtIndex:)]) {
        return [self.flowLayout RJBannerView:self sizeForItemAtIndex:RJIndex(indexPath.row)];
    }
    return self.bounds.size;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //自动滚动到右边另一页的时候被拖拽,则扔设置原页为当前页
    if (_timer && scrollView.isDecelerating && !scrollView.isTracking) {
        NSIndexPath *indexPath = _currentIndexPath;
        [self RJBannerView:self willAutoScrollToIndex:RJIndex(indexPath.row) indexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
    }
    
    [self removeTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    CGFloat centerX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    CGFloat scale = 1;
//    NSLog(@"%s ",__FUNCTION__);
    
    for (NSIndexPath *indexPath in indexPaths) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        scale = 1 - ABS(centerX - cell.center.x) / (scrollView.frame.size.width + self.minimumLineSpacing);
        
        CGFloat scaleW =1 + scale * (self.centerCellTransform.a - 1);
        CGFloat scaleH = 1 + scale * (self.centerCellTransform.d - 1);
        cell.transform = CGAffineTransformMakeScale(scaleW, scaleH);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    UICollectionViewLayoutAttributes *currentLayout = [_collectionView layoutAttributesForItemAtIndexPath:_currentIndexPath];
    long step = targetContentOffset->x > _currentOffset.x ? 1 : -1;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row + step inSection:0];
    UICollectionViewLayoutAttributes *newLayout = [_collectionView layoutAttributesForItemAtIndexPath:newIndexPath];
    CGFloat pageWidth = self.minimumLineSpacing + currentLayout.size.width / 2.0 + newLayout.size.width / 2.0;
    CGFloat nowDistance = ABS(_currentOffset.x - scrollView.contentOffset.x);
    
    if (targetContentOffset->x != scrollView.contentOffset.x || nowDistance > pageWidth / 2.0) {
        _currentIndexPath = newIndexPath;
        _currentOffset = CGPointMake(_currentOffset.x + step * pageWidth, 0);
        self.pageControl.currentPage = RJIndex(_currentIndexPath.row);
    }
    *targetContentOffset = _currentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"%s 滚动动画停止了",__FUNCTION__);
    if (scrollView.isTracking) return;

    [self addTimer];
}

@end
