//
//  WJCWorklistDataSetCell.h
//  Hi
//
//  Created by apple on 2018/5/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"
#import "WJCDescDealer.h"

@interface WJCWorklistDataSetCell : UITableViewCell

+ (instancetype)worklistDataSetCellWithTableView:(UITableView*)rTableView;

- (void)loadWithWorklistItem:(WJCHiWorklistItem*)rWorklistItem withDesc:(WJCDescDealer*) rDesc withSubindex:(uint16_t) rSubi;

@end
