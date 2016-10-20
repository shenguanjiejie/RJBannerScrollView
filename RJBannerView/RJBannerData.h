//
//  RJBannerData.h
//  duDu
//
//  Created by RuiJie on 16/10/18.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJBannerData : NSObject

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *imageName;

@property (nonatomic, copy) NSString *imageUrl;

-(instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

-(instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl;

@end
