//
//  RJBannerCollectionCell.m
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJBannerCollectionCell.h"
#import "RJBannerData.h"

@implementation RJBannerCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLab];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView,_titleLab);
        NSDictionary *metrics = @{@"margin":@5,@"titleLabH":@20};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLab(titleLabH)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:0 metrics:metrics views:views]];
    }
    return self;
}

- (void)setBannerData:(RJBannerData *)bannerData{

    _bannerData = bannerData;
    
    if (!bannerData) return;
    
    if (bannerData.imageName) {
        _imageView.image = [UIImage imageNamed:bannerData.imageName];
    }else{
        [_imageView sd_setImageWithURL:[NSURL URLWithString:bannerData.imageUrl] placeholderImage:self.placeholderImage];
    }
    
    if (bannerData.title) {
        _titleLab.text = bannerData.title;
    }
}

@end
