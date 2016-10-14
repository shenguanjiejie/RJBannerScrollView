//
//  RJBannerScrollView.h
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJBannerInfo;
@protocol  RJBannerScrollViewDelegate;

@interface RJBannerScrollView : UIView

//@property (nonatomic, assign) CGFloat pageWidth;

@property (nonatomic, assign) CGFloat minimumLineSpacing;

@property (nonatomic, assign) CGAffineTransform centerCellTransform;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, readonly, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<RJBannerInfo *> *bannerInfoArr;

@property (nonatomic, assign, getter=isAutoScroll) BOOL autoScroll;

/**
 默认3s
 */
@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic,weak) id<RJBannerScrollViewDelegate> delegate;

@property (nonatomic, strong) UIPageControl *pageControl;

- (instancetype)initWithFrame:(CGRect)frame bannerInfoArr:(NSArray<RJBannerInfo *> *)bannerInfoArr;

@end



@protocol RJBannerScrollViewDelegate <NSObject>

@optional

- (CGSize)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView sizeForItemAtIndex:(unsigned long)index;

- (void)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView didSelectItemAtIndex:(unsigned long)index;

- (void)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView willAutoScrollToIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath;

- (void)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView willDisplayingCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath;

- (void)RJBannerScrollView:(RJBannerScrollView *)bannerScrollView didEndDisplayingCell:(UICollectionViewCell *)cell atIndex:(unsigned long)index indexPath:(NSIndexPath *)indexPath;

@end
