//
//  WJCWorkllistParaEditor.h
//  Hi
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCDevice.h"
#import "WJCHiWorklist.h"

@interface WJCWorkllistParaEditor : UIViewController


- (instancetype)initWithWorklistItem:(WJCHiWorklistItem*)rWkltItem withHiDevice:(WJCDevice *)rDevice withSubindex:(int)rSubi withArrayIndex:(int)rArrI;

@end
