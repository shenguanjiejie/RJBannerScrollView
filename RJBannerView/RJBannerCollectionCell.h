//
//  RJBannerCollectionCell.h
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJItemInfo;

@interface RJBannerCollectionCell : UICollectionViewCell

@property (strong, nonatomic) RJItemInfo *itemInfo;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIView *customView;


@end
