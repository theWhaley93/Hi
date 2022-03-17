//
//  WJCDescTabItem.h
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 某个参数值意义表ITEM结构，value-description
 */
@interface WJCDescTabItem : NSObject{
    @public
    int16_t value;      //值
    NSString *desc;     //描述
}

/** 初始化
 */
- (instancetype)initWithSting:(NSString *)str;

+ (instancetype)descTabItemWithString:(NSString *)str;

/** 获取描述
 */
@property (nonatomic,copy)  NSString *useString;    //下拉的普通参数显示

@property (nonatomic,copy)  NSString *useBitString;    //下拉的bit参数显示
/**方法
 */
- (NSString *)toString;

@end
