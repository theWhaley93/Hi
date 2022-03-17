//
//  WJCCfgFilesItem.h
//  Hi
//
//  Created by apple on 2018/3/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCCfgFileModel.h"

@interface WJCCfgFilesItem : UITableViewCell


- (void)loadWithCfgFileModel:(WJCCfgFileModel *)rCfgModel;
+ (instancetype)cfgFilesItemWithTableView:(UITableView *)rTableView;

@end
