//
//  ACBaseCollectionController.h
//  ACCommon
//
//  Created by i云 on 14-6-26.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACBaseController.h"

@interface ACBaseCollectionController : ACBaseController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end
