//
//  WJCWorklistViewController.h
//  Hi
//
//  Created by apple on 2018/5/25.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"
#import "WJCDevice.h"

@interface WJCWorklistViewController : UIViewController
@property (nonatomic,strong)  WJCHiWorklist *nowWorklist;  //
@property (nonatomic,strong)  WJCDevice *nowDevice;  //

- (instancetype)initWithWorklist:(WJCHiWorklist*) rWorklist withDevice:(WJCDevice*)rDevice withIsOffline:(Boolean)rIsOffline;

@end
