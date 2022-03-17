//
//  WJCLeftViewController.h
//  Hi
//
//  Created by apple on 2018/3/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCOneGroup.h"
@protocol WJCUiLeftViewDelegate;

@interface WJCLeftViewController : UIViewController{
@public
    id theDelegate;

}

@property (nonatomic,weak)  NSMutableArray<WJCOneGroup *> *groupItems;    //需要用的组
 

@end


@protocol WJCUiLeftViewDelegate<NSObject>
@optional

- (void)changeGroupWithIndex:(int)rIndex;

@end
