//
//  WJCParameters.h
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCOneGroup.h"
#import "WJCOneParameter.h"


@interface WJCParameters : NSObject{
    
}
@property (nonatomic,copy)  NSString *configDescription;    //参数版本描述 index 65
@property (nonatomic)  NSInteger configId;    //参数版本号 index 4

//@property (nonatomic,strong)  NSMutableArray *visibleGroup;  //在参数界面可显示的参数组
@property (nonatomic,strong)  NSMutableArray<WJCOneGroup *> *actualGroup;  //实际更新上来的参数组，包含索引为0的参数
@property (nonatomic,strong)  NSMutableArray<WJCOneParameter *> *paras;  //所有的参数

//@property (nonatomic, readonly) NSArray<WJCOneGroup *> *indexPathsForVisibleRows;

@property (nonatomic,readonly)   NSInteger groupsCount;    //组数量
@property (nonatomic,readonly)   NSInteger parasCount;    //参数数量


/** 初始化
 */
//根据index获取某个参数
- (WJCOneParameter *)getOneParaWithIndex:(uint16_t)rIndex;

- (instancetype)initWithString:(NSString *)str;
+ (instancetype)parametersWithString:(NSString *)str;

/** 初始化
 */
- (NSString *)toString;

@end
