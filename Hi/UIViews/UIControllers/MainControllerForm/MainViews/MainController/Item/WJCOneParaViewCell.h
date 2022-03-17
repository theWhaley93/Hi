//
//  WJCTableViewCell.h
//  Hi
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCOneParameter.h"
#import "WJCDescDealer.h"

@interface WJCOneParaViewCell : UITableViewCell

@property (nonatomic,strong)  WJCOneParameter *onePara;  //当前参数

@property (nonatomic,strong)  WJCDescDealer *descDealer;  //参数描述

+ (instancetype)oneParaViewCellWithTableView:(UITableView *)tableView;

- (void)loadCellInfoWithPara:(WJCOneParameter *) para withParaName:(NSString*)name withDesc:(WJCDescDealer*) desc;
@end
