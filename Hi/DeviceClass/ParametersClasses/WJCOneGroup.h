//
//  WJCOneGroup.h
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCGroupItem.h"
#import "WJCOneParameter.h"
/**
    组信息
 */
@interface WJCOneGroup : NSObject{
    
}

@property (nonatomic,copy)  NSString *fullName;  //组名全称
@property (nonatomic,copy)  NSString *abbreviativeName;  //组名缩写 abbreviative adj. 缩写的，缩略的
@property (nonatomic,readonly)   NSInteger itemsCount;    //实际组元素
@property (nonatomic,readonly)   NSInteger visibleItemsCount;    //可见组元素

@property (nonatomic,strong)  NSMutableArray<WJCGroupItem *> *visibleItems;  //显示在界面上的组元素，不包括index为0的
@property (nonatomic,strong)  NSMutableArray<WJCGroupItem *> *items;  //实际组元素，包含index为0的元素

/** 初始化
 */
- (instancetype)initWithString:(NSString *)str;

+ (instancetype)oneGroupWithString:(NSString *)str;

/** 方法
 */
- (NSString *)toStringWithAllParas:(NSMutableArray<WJCOneParameter *> *)rAllParas;
@end
