//
//  RJBannerView.h
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJItemInfo.h"
#import "RJBannerCollectionCell.h"

@protocol RJBannerViewDelegate;
@protocol RJBannerViewDataSource;

@interface RJBannerView : UIView

/**
 default 0,cell之间间距
 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/**
 default 0,
 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/**
 default YES,是否允许自动滚动
 */
@property (nonatomic, assign, getter = isAutoScroll) BOOL autoScroll;

/**
 *  todo:是否分页
 */
//@property (nonatomic, assign) BOOL pageingEnabled;

/**
 *  todo:是否无限循环
 */
@property (nonatomic, assign) BOOL loopEnable;

/**
 *  当loopEnable为no的时候,才起作用,用来充当开始的占位Cell
 */
@property (nonatomic, strong) UICollectionViewCell *headerPlaceholderCell;

/**
 *  当loopEnable为no的时候,才起作用,用来充当结束的占位Cell
 */
@property (nonatomic, strong) UICollectionViewCell *footerPlaceholderCell;

/*eg:如果总数是2,设置loopEnable = NO, 那么实际为下图,切只能滚动到0 或 1,header和footer不会显示在中间
 *┏━━━━━━┓ ┏━━━━━━┓ ┏━━━━━━┓ ┏━━━━━━┓
 *┃header ┃ ┃      0    ┃ ┃      1    ┃ ┃ footer  ┃
 *┗━━━━━━┛ ┗━━━━━━┛ ┗━━━━━━┛ ┗━━━━━━┛
 */

/**
  自动滚动翻页间隔 默认3s
 */
@property (nonatomic, assign) CGFloat timeInterval;

/**
 *  cell的size
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 *  正中间显示的cell的缩放比例,如果不需要缩放,则不用设置
 */
@property (nonatomic, assign) CGAffineTransform centerCellTransform;

/**
 *  某些情况也许必须要用,但是尽量不要用
 */
@property (nonatomic, readonly, strong) UICollectionView *collectionView;

/**
 *  代理
 */
@property (nonatomic,weak) id<RJBannerViewDelegate> delegate;

/**
 *  数据源代理
 */
@property (nonatomic,weak) id<RJBannerViewDataSource> dataSource;

/**
 *  可以更改自带的pageControl或者使用你自定义的pageControl
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  增加自定义cell支持,如果自带的cell不能满足你的显示需求,你可以自定义cell,将cell的Class赋值给该属性
 */
@property (nonatomic, assign) Class customCellClass;

/**
 *  刷新BannerView的数据
 */
- (void)reloadData;

@end

@protocol RJBannerViewDataSource <NSObject>
@required

/**
 *  返回item的数量
 *
 *  @param bannerView self
 *
 *  @return 数量
 */
- (NSInteger)numberOfItemsInRJBannerView:(RJBannerView *)bannerView;

@optional

/**
 *  设置默认在中间显示的cell的index
 *
 *  @param bannerView self
 *
 *  @return 默认显示的index,index需要小于item的总数
 */
- (NSInteger)firstDisplayIndexForRJBannerView:(RJBannerView *)bannerView;

/**
 *  当loopEnable为no的时候,才会用到headerPlaceholderView,该方法会替换headerPlaceholderView属性
 *
 *  @param bannerView self
 *
 *  @return 自定义headerPlaceholderView
 */
//- (UIView *)headerPlaceholderViewForRJBannerView:(RJBannerView *)bannerView;

/**
 *  当loopEnable为no的时候,才会用到footerPlaceholderView,该方法会替换footerPlaceholderView属性
 *
 *  @param bannerView self
 *
 *  @return 自定义footerPlaceholderView
 */
//- (UIView *)footerPlaceholderViewForRJBannerView:(RJBannerView *)bannerView;

/**
 *  如果使用我默认自带的cell,使用该方法设置cell的一些特性
 *
 *  @param bannerView self
 *  @param index      该cell显示第几个item index就为几
 *
 *  @return 你自己创建RJItemInfo的实例,设置属性后将其返回
 */
- (RJItemInfo *)RJBannerView:(RJBannerView *)bannerView itemInfoForItemAtIndex:(unsigned long)index;

/**
 *  如果你使用的是自己自定义的cell,使用该方法设置cell上面显示的内容
 *
 *  @param Cell  请你自己强转为你自定义的cell
 *  @param index 该cell显示第几个item index就为几
 */
- (void)setDataForCustomCell:(UICollectionViewCell *)Cell atIndex:(unsigned long)index;

@end

@protocol RJBannerViewDelegateFlowLayout <RJBannerViewDelegate>
@optional
/**
 *  设置cell的size,建议使用itemSize进行设置
 */
- (CGSize)RJBannerView:(RJBannerView *)bannerView sizeForItemAtIndex:(unsigned long)index;

@end

@protocol RJBannerViewDelegate <NSObject>
@optional

/**
 *  选中第index个cell时调用
 *
 *  @param bannerView self
 *  @param index      该cell显示第几个item index就为几
 */
- (void)RJBannerView:(RJBannerView *)bannerView didSelectItemAtIndex:(unsigned long)index;

/**
 *  如果autoScroll属性为YES,那么g当某个cell自动滚到到中间时会调用该方法,如果autoScroll为NO,则该方法不会被调用
 *
 *  @param bannerView self
 *  @param index      该cell对应的index
 */
- (void)RJBannerView:(RJBannerView *)bannerView willAutoScrollToIndex:(unsigned long)index;

/**
 *  与UICollectionView的- (void)collectionView: willDisplayCell: forItemAtIndexPath:方法调用逻辑相同
 *
 *  @param bannerView self
 *  @param cell       将要出现的cell
 *  @param index      cell对应的index
 */
- (void)RJBannerView:(RJBannerView *)bannerView willDisplayingCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index;

/**
 *  与UICollectionView的- (void)collectionView: didEndDisplayingCell: forItemAtIndexPath:方法调用逻辑相同
 *
 *  @param bannerView self
 *  @param cell       将要消失的cell
 *  @param index      cell对应的index
 */
- (void)RJBannerView:(RJBannerView *)bannerView didEndDisplayingCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index;

/**
 *  当某个cell滚动到中间时调用,无论自动还是手动滚动,都会调用
 *
 *  @param bannerView self
 *  @param cell       到中间的cell
 *  @param index      cell对应index
 */
- (void)RJBannerView:(RJBannerView *)bannerView willScrollToCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index;

/**
 *  当某个cell滚动离开中间时调用,无论自动还是手动滚动,都会调用
 *
 *  @param bannerView self
 *  @param cell       离开的cell
 *  @param index      cell对应的index
 */
- (void)RJBannerView:(RJBannerView *)bannerView willEndScrollToCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index;


@end
