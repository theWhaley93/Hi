//
//  WJCWorklistDataSetController.h
//  Hi
//
//  Created by apple on 2018/5/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCDevice.h"

@interface WJCWorklistDataSetController : UITableViewController

- (instancetype)initWithWorklistItem:(WJCHiWorklistItem*)rItem withHiDevice:(WJCDevice*)rDevice;

@end
