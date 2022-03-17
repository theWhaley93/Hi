//
//  WJCWorklistEditorView.h
//  twoTableViews
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCParameters.h"
#import "WJCHiWorklist.h"

@interface WJCWorklistEditorView : UIViewController

- (instancetype)initWithHiPara:(WJCParameters *)rHiPara withWorklist:(WJCHiWorklist*)rWorklist;

@end
