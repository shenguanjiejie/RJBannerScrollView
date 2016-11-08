//
//  RJBannerData.h
//  duDu
//
//  Created by RuiJie on 16/10/18.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJBannerData : NSObject



-(instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

-(instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl;

@end
