//
//  WJCArrayParaCell.h
//  Hi
//
//  Created by apple on 2018/4/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCOneParameter.h"
#import "WJCDescDealer.h"
#import "WJCHiWorklist.h"

@protocol WJCArrayParaClickDelegate;

@interface WJCArrayParaCell : UITableViewCell

+ (instancetype)arrayParaWithTableView:(UITableView *)tableView;

- (void)loadCellInfoWithPara:(WJCOneParameter *) rPara withRow:(NSInteger)rRow withSubindex:(int)rSub withDesc:(WJCDescDealer*) desc withDelegate:(id)rDelegate;

- (void)loadCellInfoWithWorklistItem:(WJCHiWorklistItem *) rWorklistItem withRow:(NSInteger)rRow withSubindex:(int)rSub withDesc:(WJCDescDealer*) desc withDelegate:(id)rDelegate;
@end

@protocol WJCArrayParaClickDelegate <NSObject>
@optional   //可选的方法
/**按钮动作

 */
- (void)clickWithRow:(int)rRow withIndex:(int)rIndex;
@end

