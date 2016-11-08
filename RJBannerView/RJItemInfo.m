//
//  RJItemInfo.m
//  duDu
//
//  Created by RuiJie on 16/10/31.
//  Copyright © 2016年 youd. All rights reserved.
//

#import "RJItemInfo.h"

@implementation RJItemInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shadowOffset = CGSizeZero;
        _shadowColor = [UIColor clearColor];
        _shadowOpacity = 0;
        _shadowRadius = 0;
        _textColor = [UIColor whiteColor];
        _textFont = [UIFont systemFontOfSize:16];
    }
    
    return self;
}

@end
