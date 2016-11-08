//
//  RJItemInfo.h
//  duDu
//
//  Created by RuiJie on 16/10/31.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJItemInfo : NSObject

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *imageName;

@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIFont *textFont;

@property (nonatomic, strong) UIImage *placeholderImage;

/**
 阴影透明度
 */
@property (nonatomic, assign) CGFloat shadowOpacity;

/**
 阴影大小
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 阴影颜色
 */
@property (nonatomic, strong) UIColor *shadowColor;

/**
 阴影offset
 */
@property (nonatomic, assign)  CGSize shadowOffset;

@end
