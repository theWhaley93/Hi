//
//  WJCWorklistViewCell.h
//  Hi
//
//  Created by apple on 2018/5/2.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"
#import "WJCDescDealer.h"

@interface WJCWorklistViewCell : UITableViewCell



+ (instancetype)worklistViewCellWithTableView:(UITableView *)tableView;
- (void)loadWorklistItem:(WJCHiWorklistItem*)rWorklistItem withDesc:(WJCDescDealer*) rDesc;

@end
