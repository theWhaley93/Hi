//
//  WJCWorklistController.h
//  Hi
//
//  Created by apple on 2018/4/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"
#import "WJCDevice.h"

@interface WJCWorklistController : UITableViewController

@property (nonatomic,strong)  WJCHiWorklist *nowWorklist;  //
@property (nonatomic,strong)  WJCDevice *nowDevice;  //

- (instancetype)initWithWorklist:(WJCHiWorklist*) rWorklist withDevice:(WJCDevice*)rDevice withIsOffline:(Boolean)rIsOffline;

@end
