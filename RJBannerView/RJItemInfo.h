//
//  RJItemInfo.h
//  duDu
//
//  Created by RuiJie on 16/10/31.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJItemInfo : NSObject

#pragma mark - 文本相关
/**
 *  @"图片介绍"
 */
@property (copy, nonatomic) NSString *title;

/**
 *  文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 *  字体
 */
@property (nonatomic, strong) UIFont *textFont;

/**
 *  文字contentMode
 */
@property (nonatomic, assign) NSTextAlignment textAligment;

#pragma mark - 图片相关
/**
 *  图片名,优先级大于imageUrl
 */
@property (copy, nonatomic) NSString *imageName;

/**
 *  图片url,优先级低于imageName
 */
@property (nonatomic, copy) NSString *imageUrl;

/**
 *  占位图片
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 *  图片的contentMode
 */
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

#pragma mark - 阴影相关
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
