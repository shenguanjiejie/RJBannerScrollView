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

#define RJTotleRow (_loopEnable ? 5000 * _count : _count + 2)
#define RJDefaultRow (unsigned long)(RJTotleRow * 0.5 + _firstDisplayIndex)
#define RJIndex(indexPathRow) (_loopEnable ? ((indexPathRow) % _count) : (indexPathRow - 1))
#define RJIsPlaceholderCell (!self.loopEnable && (indexPath.row == 0 || indexPath.row == RJTotleRow - 1))

@implementation NSObject (RJbannerView)

- (NSInteger)numberOfItemsInRJBannerView:(__unused RJBannerView *)bannerView{return 0;}

- (NSInteger)firstDisplayIndexForRJBannerView:(__unused RJBannerView *)bannerView{return 0;}

- (RJItemInfo *)RJBannerView:(__unused RJBannerView *)bannerView itemInfoForItemAtIndex:(unsigned long)index{return [[RJItemInfo alloc] init];}

- (void)setDataForCustomCell:(__unused UICollectionViewCell *)Cell atIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView didSelectItemAtIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView willAutoScrollToIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView willDisplayingCell:(__unused UICollectionViewCell *)cell atIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView didEndDisplayingCell:(__unused UICollectionViewCell *)cell atIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView willScrollToCell:(__unused UICollectionViewCell *)cell atIndex:(unsigned long)index{}

- (void)RJBannerView:(__unused RJBannerView *)bannerView willEndScrollToCell:(__unused UICollectionViewCell *)cell atIndex:(unsigned long)index{}

@end

@interface RJBannerView()  <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSTimer *_timer;
    CGPoint _currentOffset;
    NSIndexPath *_currentIndexPath;
    unsigned long _count;
    unsigned long _firstDisplayIndex;
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
        _loopEnable = YES;
        _centerCellTransform = CGAffineTransformMakeScale(1.0, 1.0);

        RJCollectionViewFlowLayout *layout= [[RJCollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0;
        layout.itemSize = self.bounds.size;
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

- (void)setItemSize:(CGSize)itemSize{
    if (CGSizeEqualToSize(itemSize, _itemSize)) {
        return;
    }
    
    _itemSize = itemSize;
    
    RJCollectionViewFlowLayout *folwLayout = (RJCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    folwLayout.itemSize = _itemSize;
    self.collectionView.collectionViewLayout = folwLayout;
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
    if (_pageControl) {
        [_pageControl removeFromSuperview];
    }
    _pageControl = pageControl;
}

- (void)setCustomCellClass:(Class)customCellClass{
    if (customCellClass && [customCellClass isSubclassOfClass:[UICollectionViewCell class]]) {
        [_collectionView registerClass:customCellClass forCellWithReuseIdentifier:@"customCell"];
        _customCellClass = customCellClass;
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

- (void)setHeaderPlaceholderCell:(UICollectionViewCell *)headerPlaceholderCell{
    _headerPlaceholderCell = headerPlaceholderCell;
    if (headerPlaceholderCell) {
        [_collectionView registerClass:[self.headerPlaceholderCell class] forCellWithReuseIdentifier:@"headerPlaceholderCell"];
    }
}

- (void)setFooterPlaceholderCell:(UICollectionViewCell *)footerPlaceholderCell{
    _footerPlaceholderCell = footerPlaceholderCell;
    if (footerPlaceholderCell) {
        [_collectionView registerClass:[self.footerPlaceholderCell class] forCellWithReuseIdentifier:@"footerPlaceholderCell"];
    }
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
        if (RJDefaultRow > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:RJDefaultRow inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            _currentOffset = _collectionView.contentOffset;
            _currentIndexPath = indexPath;
            if (!_timer && self.isAutoScroll) {
                [self addTimer];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
                [self.delegate RJBannerView:self willScrollToCell:cell atIndex:RJIndex(RJDefaultRow)];
            });
        }
    });
    
}

- (void)RJBannerView:(RJBannerView *)bannerView willAutoScrollToIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *nextCell = [_collectionView cellForItemAtIndexPath:indexPath];
    UICollectionViewCell *currentCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
    
    //为layout设置将要跳转到的cell位置的offset
    _currentOffset = CGPointMake(_collectionView.contentOffset.x + self.minimumLineSpacing + currentCell.frame.size.width / 2.0 + nextCell.frame.size.width / 2.0, 0);
    _currentIndexPath = indexPath;
    
    if (self.pageControl) {
        self.pageControl.currentPage = RJIndex(_currentIndexPath.row);
    }
    
    [self.delegate RJBannerView:self willScrollToCell:nextCell atIndex:index];
    [self.delegate RJBannerView:self willEndScrollToCell:currentCell atIndex:RJIndex(_currentIndexPath.row)];
    [self.delegate RJBannerView:self willAutoScrollToIndex:index];
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
    if (!indexs) {
        return;
    }
    
    for (NSIndexPath *index in indexs) {
        row = MAX(row, index.row);
    }
    
    if (!self.loopEnable && row == RJTotleRow - 1) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self RJBannerView:self willAutoScrollToIndex:RJIndex(indexPath.row) indexPath:indexPath];
}

#pragma mark - 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    _count = [self.dataSource numberOfItemsInRJBannerView:self];
    
    _firstDisplayIndex = [self.dataSource firstDisplayIndexForRJBannerView:self];
    if (_firstDisplayIndex >= _count) {
        _firstDisplayIndex = 0;
    }
    
    if (self.pageControl) {
        self.pageControl.numberOfPages = _count;
    }
    
    return RJTotleRow;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    static NSString *ID = @"Cell";
    if (!self.loopEnable) {
        if (indexPath.row == 0) {
            if (self.headerPlaceholderCell) {
                static NSString *headerCellID = @"feaderPlaceholderCell";
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:headerCellID forIndexPath:indexPath];
            }else{
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            }
            
            return cell;
        }else if (indexPath.row == RJTotleRow - 1){
            if (self.headerPlaceholderCell) {
                static NSString *footerCellID = @"footerPlaceholderCell";
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:footerCellID forIndexPath:indexPath];
            }else {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
            }
            return cell;
        }
    }
    
    if (self.customCellClass) {
        static NSString *customCellID = @"customCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:customCellID forIndexPath:indexPath];
        [self.dataSource setDataForCustomCell:cell atIndex:RJIndex(indexPath.row)];
    }else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
        ((RJBannerCollectionCell *)cell).itemInfo = [self.dataSource RJBannerView:self itemInfoForItemAtIndex:RJIndex(indexPath.row)];
    }
    
    if (indexPath.row == RJDefaultRow) {
        cell.transform = self.centerCellTransform;
    }
//    cell.titleLab.text = [NSString stringWithFormat:@"indexRow = %ld",indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (RJIsPlaceholderCell) {
        return;
    }
    [self.delegate RJBannerView:self willDisplayingCell:cell atIndex:RJIndex(indexPath.row)];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (RJIsPlaceholderCell) {
        return;
    }
    [self.delegate RJBannerView:self didEndDisplayingCell:cell atIndex:RJIndex(indexPath.row)];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (RJIsPlaceholderCell) {
        return;
    }
    [self.delegate RJBannerView:self didSelectItemAtIndex:RJIndex(indexPath.row)];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        return self.itemSize;
    }
    
    if ([self.flowLayout respondsToSelector:@selector(RJBannerView:sizeForItemAtIndex:)]) {
        return [self.flowLayout RJBannerView:self sizeForItemAtIndex:RJIndex(indexPath.row)];
    }
    
    static dispatch_once_t onceToken;
    static CGSize size;
    dispatch_once(&onceToken, ^{
        size = self.bounds.size;
    });
    return size;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //自动滚动到右边另一页的时候被拖拽,则扔设置原页为当前页 (貌似不会被调用)
    if (_timer && scrollView.isDecelerating && !scrollView.isTracking) {
        NSIndexPath *indexPath = _currentIndexPath;
        [self RJBannerView:self willAutoScrollToIndex:RJIndex(indexPath.row) indexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
    }
    
    [self removeTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.centerCellTransform.a == 1 && self.centerCellTransform.d == 1) {
        return;
    }
    
    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
    CGFloat centerX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    static CGFloat scale = 1;
    
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

    static int step;
    if (ABS(velocity.x) > 0.1) {
        step = velocity.x > 0 ? 1 : -1;
    }else{
        step = scrollView.contentOffset.x > _currentOffset.x ? 1 : -1;
    }

    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row + step inSection:0];
    
    if (!self.loopEnable && ((step == -1 && newIndexPath.row == 0) || (step == 1 && newIndexPath.row == RJTotleRow - 1))) {
        *targetContentOffset = _currentOffset;
        return;
    }
    
    UICollectionViewLayoutAttributes *newLayout = [_collectionView layoutAttributesForItemAtIndexPath:newIndexPath];
    CGFloat pageWidth = self.minimumLineSpacing + currentLayout.size.width / 2.0 + newLayout.size.width / 2.0;
    CGFloat nowDistance = ABS(_currentOffset.x - scrollView.contentOffset.x);
    
//    NSLog(@"%s %@",__FUNCTION__,_currentIndexPath);
    
    if (ABS(velocity.x) > 0.1 || nowDistance > pageWidth / 2.0) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:_currentIndexPath];
        UICollectionViewCell *nextCell = [_collectionView cellForItemAtIndexPath:newIndexPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate RJBannerView:self willEndScrollToCell:cell atIndex:RJIndex(_currentIndexPath.row)];
            [self.delegate RJBannerView:self willScrollToCell:nextCell atIndex:RJIndex(newIndexPath.row)];
        });
        
        _currentIndexPath = newIndexPath;
        _currentOffset = CGPointMake(_currentOffset.x + step * pageWidth, 0);
        if (self.pageControl) {
            self.pageControl.currentPage = RJIndex(_currentIndexPath.row);
        }
//        NSLog(@"%@",newIndexPath);
    }
    
    *targetContentOffset = _currentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.isTracking) return;

    if (self.isAutoScroll) {
        [self addTimer];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
