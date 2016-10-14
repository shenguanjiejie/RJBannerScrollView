//
//  RJBannerCollectionCell.h
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJBannerInfo;

@interface RJBannerCollectionCell : UICollectionViewCell

@property (strong, nonatomic) RJBannerInfo *bannerInfo;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImage *placeholderImage;



@end