//
//  RJBannerInfo.h
//  duDu
//
//  Created by RuiJie on 16/10/11.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SingletonH(name) + (instancetype)shared##name;
#define SingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone { \
return _instance; \
}

@interface RJBannerInfo : NSObject

SingletonH(RJBannerInfo)

/**
 自动滚动翻页间隔 默认3s
 */
@property (nonatomic, assign) CGFloat timeInterval;

/**
 cell伸缩动画时间,默认0.1s
 */
@property (nonatomic, assign) CGFloat transformDuration;

@property (nonatomic, assign) CGAffineTransform centerCellTransform;

@property (nonatomic, assign) CGPoint currentOffset;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@end
