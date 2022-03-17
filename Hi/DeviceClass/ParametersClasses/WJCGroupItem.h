//
//  WJCGroupItem.h
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 存在组的元素
 */
@interface WJCGroupItem : NSObject{
    @public
    uint16_t index;
    NSString *abbreviativeName;
}

/**
 初始化类
 */
//在worklist编辑的时候使用
@property (nonatomic)  Boolean isSelect;  //worklist是否选中
@property (nonatomic,strong)  NSString *settingVal;  //worklist的设定值


- (instancetype)initWithindex:(uint16_t)ind name:(NSString *)sname;
+ (instancetype)groupItemWithindex:(uint16_t)ind name:(NSString *)sname;

@end
