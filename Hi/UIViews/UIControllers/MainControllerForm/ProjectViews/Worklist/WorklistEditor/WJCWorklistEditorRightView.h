//
//  WJCWorklistEditorRightView.h
//  Hi
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiWorklist.h"

@interface WJCWorklistEditorRightView : UIView

- (void)reloadTable;
- (instancetype)initWithFrame:(CGRect)rFrame withWorklist:(WJCHiWorklist *)rWorklist;

@end
