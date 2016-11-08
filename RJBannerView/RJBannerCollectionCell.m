//
//  RJBannerCollectionCell.m
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJBannerCollectionCell.h"
#import "RJItemInfo.h"

@interface RJBannerCollectionCell ()

@end

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

- (void)setItemInfo:(RJItemInfo *)itemInfo{

    _itemInfo = itemInfo;
    
    if (!itemInfo) return;
    
    if (itemInfo.imageName) {
        _imageView.image = [UIImage imageNamed:itemInfo.imageName];
    }else{
        [_imageView sd_setImageWithURL:[NSURL URLWithString:itemInfo.imageUrl] placeholderImage:itemInfo.placeholderImage];
    }
    
    _titleLab.text = itemInfo.title ? itemInfo.title : @"";
    _titleLab.textColor = itemInfo.textColor;
    _titleLab.font = itemInfo.textFont;
    
    self.layer.shadowColor = itemInfo.shadowColor.CGColor;
    self.layer.shadowOpacity = itemInfo.shadowOpacity;
    self.layer.shadowOffset = itemInfo.shadowOffset;
    self.layer.shadowRadius = itemInfo.shadowRadius;
    
}

@end
