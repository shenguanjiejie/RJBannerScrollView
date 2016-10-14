//
//  RJBannerInfo.m
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJBannerInfo.h"

@implementation RJBannerInfo

-(instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName{
    if (self = [super init]) {
        self.title = title;
        self.imageName = imageName;
    }
    
    return self;
}

-(instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl{
    if (self = [super init]) {
        self.title = title;
        self.imageUrl = imageUrl;
    }
    
    return self;
}

@end
