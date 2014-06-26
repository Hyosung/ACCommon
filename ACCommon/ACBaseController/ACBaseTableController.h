//
//  ACBaseTableController.h
//  ACCommon
//
//  Created by i云 on 14-6-26.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "ACBaseController.h"

@interface ACBaseTableController : ACBaseController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end
