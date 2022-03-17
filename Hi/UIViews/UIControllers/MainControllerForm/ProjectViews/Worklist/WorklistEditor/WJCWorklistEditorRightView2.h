//
//  WJCWorklistEditorRightView2.h
//  Hi
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"

@interface WJCWorklistEditorRightView2 : UIViewController

- (instancetype)initWithWorklist:(WJCHiWorklist *)rWorklist;
- (void)reloadTable;
@end
