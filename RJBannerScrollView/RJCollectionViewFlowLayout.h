//
//  RJCollectionViewFlowLayout.h
//  duDu
//
//  Created by RuiJie on 16/10/12.
//  Copyright © 2016年 youd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGPoint currentOffset;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

//@property (nonatomic, assign) CGFloat pageWidth;

@property (nonatomic, assign) CGAffineTransform centerCellTransform;

@end
