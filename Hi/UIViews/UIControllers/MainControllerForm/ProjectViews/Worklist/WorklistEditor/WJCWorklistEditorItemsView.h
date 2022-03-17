//
//  WJCWorklistEditorItemsView.h
//  twoTableViews
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCParameters.h"
#import "WJCHiWorklist.h"

@protocol ProductsDelegate <NSObject>


- (void)willDisplayHeaderView:(NSInteger)section;
- (void)didEndDisplayingHeaderView:(NSInteger)section;

@end


@interface WJCWorklistEditorItemsView : UIViewController

@property(nonatomic, weak) id<ProductsDelegate> delegate;

- (void)scrollToSelectedIndexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithHiPara:(WJCParameters *)rHiPara withActualWorklist:(WJCHiWorklist*)rWorklist withTempWorklist:(WJCHiWorklist*)rTempWorklist;

@end
